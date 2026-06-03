#!/usr/bin/env bash
# PostToolUse(Edit|Write) hook — format a single edited file in place.
#
# Non-blocking and best-effort: it never fails an edit, and it no-ops on any
# file type or project that has no formatter wired up (so editing dotfiles
# markdown, shell scripts, etc. does nothing). The end-of-phase gate
# (implementation-checks.sh) verifies formatting; this just keeps files clean
# the instant they're written. Written for bash 3.2 (macOS system bash).

input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0

file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] && [ -f "$file" ] || exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null

case "$file" in
  *.ex|*.exs)
    if [ -f mix.exs ] && command -v mix >/dev/null 2>&1; then
      mix format "$file" >/dev/null 2>&1
    fi
    ;;
  *.py)
    if command -v uv >/dev/null 2>&1 && { [ -f uv.lock ] || [ -f pyproject.toml ]; }; then
      uv run ruff format "$file" >/dev/null 2>&1
    elif command -v ruff >/dev/null 2>&1; then
      ruff format "$file" >/dev/null 2>&1
    fi
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.css|*.scss|*.json|*.md|*.html|*.yml|*.yaml)
    # Only when the project genuinely uses prettier — avoids reformatting
    # files in repos that have no opinion about them.
    if [ -x node_modules/.bin/prettier ]; then
      node_modules/.bin/prettier --write "$file" >/dev/null 2>&1
    fi
    ;;
esac

exit 0
