#!/usr/bin/env bash
# Format/lint/test gate. Single hook context:
#
#   PreToolUse  matcher "Skill", if: Skill(commit)
#
# Every code change now lands through the `commit` skill — implementation and
# fix phases commit as they go — so gating commits gates everything. This used
# to also run on SubagentStop and Stop; those were removed once phases started
# committing, since they duplicated this run.
#
# One-shot and blocking: exit 2 with the failures on stderr so the commit is
# refused and the model fixes them before retrying. No retry counter — the
# model re-invokes /commit, which re-runs this.
#
# Checks are scoped to working-tree changes (staged + unstaged + untracked).
#
# bash 3.2 safe (macOS system bash): no mapfile, no `set -u`.

export PATH="$HOME/.asdf/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

command -v jq  >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')

[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" 2>/dev/null || exit 0

# Collect changed files: unstaged + staged + new untracked, deduped.
changed=()
while IFS= read -r line; do
  [ -n "$line" ] && [ -f "$line" ] && changed+=("$line")
done < <( { git diff --name-only; git diff --name-only --cached; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u )

# Nothing changed → nothing to gate.
[ "${#changed[@]}" -eq 0 ] && exit 0

# Partition by language.
ex=(); py=(); js=(); ex_tests=(); py_tests=()
for f in "${changed[@]}"; do
  case "$f" in
    *.ex|*.exs)            ex+=("$f");  case "$f" in *_test.exs) ex_tests+=("$f");; esac ;;
    *.py)                  py+=("$f");  case "$f" in test_*.py|*_test.py|*/tests/*.py) py_tests+=("$f");; esac ;;
    *.js|*.jsx|*.ts|*.tsx) js+=("$f") ;;
  esac
done

fail=""
note() { fail="${fail}$1"$'\n'; }

# ---- Elixir ----
# Find the nearest mix.exs by walking up from the first changed .ex/.exs file.
# This handles monorepos where mix.exs lives in a sub-app (e.g. apps/axon/),
# not at the git root.
find_mix_root() {
  local f="$1" d
  d=$(cd "$(dirname "$f")" 2>/dev/null && pwd) || return 1
  while [ "$d" != "/" ]; do
    [ -f "$d/mix.exs" ] && { echo "$d"; return 0; }
    d=$(dirname "$d")
  done
  return 1
}
if [ "${#ex[@]}" -gt 0 ] && command -v mix >/dev/null 2>&1; then
  mix_root=$(find_mix_root "${ex[0]}")
  if [ -n "$mix_root" ]; then
    # Make paths relative to mix_root so mix commands work correctly.
    # Files in changed[] are relative to $root (git root); mix_root is absolute.
    ex_rel=(); for f in "${ex[@]}"; do abs="$root/$f"; ex_rel+=("${abs#${mix_root}/}"); done
    ex_tests_rel=(); for f in "${ex_tests[@]}"; do abs="$root/$f"; ex_tests_rel+=("${abs#${mix_root}/}"); done
    (
      cd "$mix_root" || exit 0
      if ! out=$(mix format --check-formatted "${ex_rel[@]}" 2>&1); then
        printf 'FORMAT (elixir): run `mix format %s`\n%s\n' "${ex_rel[*]}" "$out"
      fi
      if mix help credo >/dev/null 2>&1; then
        if ! out=$(mix credo --strict "${ex_rel[@]}" 2>&1); then
          printf 'LINT (mix credo):\n%s\n' "$out"
        fi
      fi
      if [ "${#ex_tests_rel[@]}" -gt 0 ]; then
        if ! out=$(mix test "${ex_tests_rel[@]}" 2>&1); then
          printf 'TESTS (mix test, changed files) FAILING:\n%s\n' "$out"
        fi
      fi
    ) | while IFS= read -r line; do note "$line"; done
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
[ -z "$fail" ] && exit 0

# Truncate so we never dump a giant payload back to the model.
fail=$(printf '%s' "$fail" | tail -n 200)

{
  echo "BLOCKED — fix format/lint/test issues before committing."
  echo "Checked: all staged + unstaged changed files (and any changed test files)."
  echo
  printf '%s\n' "$fail"
  echo
  echo "Fix the above, then run /commit again."
} >&2
exit 2
