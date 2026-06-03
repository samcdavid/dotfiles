#!/usr/bin/env bash
# PreToolUse(Skill) hook — if: Skill(commit)
#
# Runs format-check + lint on all changed files (staged + unstaged + new
# untracked) before the commit skill begins. Blocks if anything fails so the
# author fixes issues before investing time planning commit messages.
#
# No tests — those are the implementation phase's job (implementation-checks.sh).
# No retry counter — this is a one-shot gate; fix and re-invoke the skill.
# bash 3.2 safe.

export PATH="$HOME/.asdf/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

command -v jq  >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || exit 0

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" 2>/dev/null || exit 0

# All changed files: staged + unstaged + new untracked, deduped.
changed=()
while IFS= read -r line; do
  [ -n "$line" ] && [ -f "$line" ] && changed+=("$line")
done < <( { git diff --name-only; git diff --name-only --cached; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u )

[ "${#changed[@]}" -eq 0 ] && exit 0

ex=(); py=(); js=()
for f in "${changed[@]}"; do
  case "$f" in
    *.ex|*.exs) ex+=("$f") ;;
    *.py)       py+=("$f") ;;
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
fi

# ---- Python ----
if [ "${#py[@]}" -gt 0 ]; then
  RUFF=""
  if command -v uv >/dev/null 2>&1 && { [ -f uv.lock ] || [ -f pyproject.toml ]; }; then
    RUFF="uv run ruff"
  elif command -v ruff >/dev/null 2>&1; then
    RUFF="ruff"
  fi
  if [ -n "$RUFF" ]; then
    if ! out=$($RUFF format --check "${py[@]}" 2>&1); then
      note "FORMAT (python): run \`$RUFF format ${py[*]}\`"$'\n'"$out"
    fi
    if ! out=$($RUFF check "${py[@]}" 2>&1); then
      note "LINT (ruff check):"$'\n'"$out"
    fi
  fi
fi

# ---- JS / TS ----
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

[ -z "$fail" ] && exit 0

fail=$(printf '%s' "$fail" | tail -n 200)

{
  echo "BLOCKED — fix format/lint issues before committing."
  echo "Checked: all staged + unstaged changed files."
  echo
  printf '%s\n' "$fail"
  echo
  echo "Fix the above, then run /commit again."
} >&2
exit 2
