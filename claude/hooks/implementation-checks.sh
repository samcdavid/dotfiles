#!/usr/bin/env bash
# SubagentStop hook — matcher: implementation-executor
#
# Gate that fires when an implementation-executor finishes a phase. It scopes to
# the files that phase changed (unstaged + staged + new untracked) and enforces,
# per detected stack:
#   1. formatting   (mix format --check-formatted / ruff format --check / prettier --check)
#   2. linting      (mix credo / ruff check / eslint)
#   3. introduced tests pass (only the changed/new *test* files)
#
# On failure it HARD-BLOCKS (exit 2): stderr is shown to the executor, which must
# fix and re-finish. A per-agent retry counter caps blocking so it can never loop
# forever — after MAX_RETRIES it releases control and the my-implement orchestrator
# catches the failure in its own re-verify step.
#
# Scope notes / known limits:
#   - Runs from the git top level; assumes the project manifest lives there
#     (single-project repos and umbrella roots). Nested monorepo packages are not
#     auto-detected — refine per project if needed.
#   - Lint/format/test are scoped to CHANGED files only, so pre-existing issues in
#     untouched files never block a phase.
#   - Tests that need a database/services may fail for infra reasons; that surfaces
#     as a (recoverable) block and, after the retry cap, escalates.
# Written for bash 3.2 (macOS system bash): no mapfile, no `set -u`.

MAX_RETRIES=2

input=$(cat)
command -v jq  >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
agent_id=$(printf '%s' "$input" | jq -r '.agent_id // empty')
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || exit 0

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" 2>/dev/null || exit 0

# Collect changed files: unstaged + staged + new untracked, deduped.
changed=()
while IFS= read -r line; do
  [ -n "$line" ] && [ -f "$line" ] && changed+=("$line")
done < <( { git diff --name-only; git diff --name-only --cached; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u )

cnt_file="/tmp/claude-impl-checks-${agent_id:-unknown}.cnt"

# Nothing changed (e.g. a read-only phase) → nothing to gate.
if [ "${#changed[@]}" -eq 0 ]; then
  rm -f "$cnt_file" 2>/dev/null
  exit 0
fi

# Partition by language.
ex=(); py=(); js=(); ex_tests=(); py_tests=()
for f in "${changed[@]}"; do
  case "$f" in
    *.ex|*.exs)        ex+=("$f");  case "$f" in *_test.exs) ex_tests+=("$f");; esac ;;
    *.py)              py+=("$f");  case "$f" in test_*.py|*_test.py|*/tests/*.py) py_tests+=("$f");; esac ;;
    *.js|*.jsx|*.ts|*.tsx) js+=("$f") ;;
  esac
done

fail=""
note() { fail="${fail}$1"$'\n'; }

# ---- Elixir ----
if [ "${#ex[@]}" -gt 0 ] && [ -f mix.exs ] && command -v mix >/dev/null 2>&1; then
  if ! out=$(mix format --check-formatted "${ex[@]}" 2>&1); then
    note "FORMAT (elixir): run \`mix format ${ex[*]}\`"$'\n'"$out"
  fi
  if mix help credo >/dev/null 2>&1; then
    if ! out=$(mix credo --strict "${ex[@]}" 2>&1); then
      note "LINT (mix credo):"$'\n'"$out"
    fi
  fi
  if [ "${#ex_tests[@]}" -gt 0 ]; then
    if ! out=$(mix test "${ex_tests[@]}" 2>&1); then
      note "TESTS (mix test, changed files) FAILING:"$'\n'"$out"
    fi
  fi
fi

# ---- Python ----
if [ "${#py[@]}" -gt 0 ]; then
  RUFF=""; PYTEST=""
  if command -v uv >/dev/null 2>&1 && { [ -f uv.lock ] || [ -f pyproject.toml ]; }; then
    RUFF="uv run ruff"; PYTEST="uv run pytest"
  elif command -v ruff >/dev/null 2>&1; then
    RUFF="ruff"; command -v pytest >/dev/null 2>&1 && PYTEST="pytest"
  fi
  if [ -n "$RUFF" ]; then
    if ! out=$($RUFF format --check "${py[@]}" 2>&1); then
      note "FORMAT (python): run \`$RUFF format ${py[*]}\`"$'\n'"$out"
    fi
    if ! out=$($RUFF check "${py[@]}" 2>&1); then
      note "LINT (ruff check):"$'\n'"$out"
    fi
  fi
  if [ -n "$PYTEST" ] && [ "${#py_tests[@]}" -gt 0 ]; then
    if ! out=$($PYTEST "${py_tests[@]}" 2>&1); then
      note "TESTS (pytest, changed files) FAILING:"$'\n'"$out"
    fi
  fi
fi

# ---- JS / TS (format + lint; test runner is project-specific, skipped here) ----
if [ "${#js[@]}" -gt 0 ] && [ -d node_modules ]; then
  if [ -x node_modules/.bin/prettier ]; then
    if ! out=$(node_modules/.bin/prettier --check "${js[@]}" 2>&1); then
      note "FORMAT (js): run \`npx prettier --write ${js[*]}\`"$'\n'"$out"
    fi
  fi
  if [ -x node_modules/.bin/eslint ]; then
    if ! out=$(node_modules/.bin/eslint "${js[@]}" 2>&1); then
      note "LINT (eslint):"$'\n'"$out"
    fi
  fi
fi

# ---- Verdict ----
if [ -z "$fail" ]; then
  rm -f "$cnt_file" 2>/dev/null
  exit 0
fi

# Truncate so we never dump a giant payload back to the model.
fail=$(printf '%s' "$fail" | tail -n 200)

count=0
[ -f "$cnt_file" ] && count=$(cat "$cnt_file" 2>/dev/null || echo 0)
case "$count" in ''|*[!0-9]*) count=0 ;; esac

if [ "$count" -ge "$MAX_RETRIES" ]; then
  # Bounded-retry guard: stop blocking so we cannot loop forever. The executor
  # returns; my-implement's independent re-verify + loop detection take over.
  rm -f "$cnt_file" 2>/dev/null
  jq -n --arg m "Implementation checks still failing after $((MAX_RETRIES + 1)) attempts — releasing the executor. It should report Result: ESCALATE; the my-implement orchestrator will re-verify and apply loop detection.

$fail" '{continue: true, systemMessage: $m}'
  exit 0
fi

echo $((count + 1)) > "$cnt_file"

{
  echo "BLOCKED — phase checks failed; fix before finishing (attempt $((count + 1)) of $((MAX_RETRIES + 1)))."
  echo "Only the files you changed this phase were checked."
  echo
  printf '%s\n' "$fail"
  echo
  echo "Fix the above, then finish normally — checks re-run automatically. If the SAME failure persists, finish with Result: ESCALATE instead of retrying."
} >&2
exit 2
