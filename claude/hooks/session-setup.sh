#!/usr/bin/env bash
# SessionStart hook — install dependencies + do an initial compile.
#
# Runs async (the hook is configured async:true) and idempotent: it skips work
# whenever the dependency dir already exists and the lockfile hasn't changed, so
# it's a fast no-op on a warm repo and only does real work on a cold checkout or
# after a lockfile update.
#
# Monorepo-aware via a simple, robust rule: an "install root" is any directory
# containing a LOCKFILE. That way an Elixir umbrella or a JS/pnpm/uv workspace is
# handled once at its root (sub-projects have no lockfile of their own), while a
# genuinely separate app (e.g. a Node app under apps/) gets its own setup. A
# fresh project with a manifest but no lockfile yet is handled by the fallbacks.
#
# Output is appended to <repo>/.git/claude-autosetup.log (inside .git, never
# tracked). bash 3.2 safe (no mapfile, no `set -u`).

# Hooks run in a non-interactive shell that hasn't sourced the user's profile, so
# asdf shims / Homebrew tools may be missing from PATH. Put them back.
export PATH="$HOME/.asdf/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

input=$(cat)
command -v jq  >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" 2>/dev/null || exit 0

log="$root/.git/claude-autosetup.log"
# Keep the log from growing without bound.
if [ -f "$log" ] && [ "$(wc -l < "$log" 2>/dev/null || echo 0)" -gt 500 ]; then
  tail -n 200 "$log" > "$log.tmp" 2>/dev/null && mv "$log.tmp" "$log" 2>/dev/null
fi

say() { printf '%s %s\n' "$(date '+%H:%M:%S')" "$1" >> "$log"; }

# needs <lockfile> <depdir> → true when the dep dir is missing or out of date.
needs() { [ ! -d "$2" ] || [ "$1" -nt "$2" ]; }

# run_in <dir> <cmd...> → run a command in a dir, logging result. Never fatal.
run_in() {
  rdir=$1; shift
  say "  [$rdir] \$ $*"
  if ( cd "$rdir" && "$@" ) >> "$log" 2>&1; then say "    ok"; else say "    FAILED — see log above"; fi
}

# find_roots <lockfile-name> → print each dir containing that lockfile, pruning
# vendored/build dirs and limiting depth so large monorepos stay fast.
find_roots() {
  find "$root" -maxdepth 5 \
    \( -name node_modules -o -name deps -o -name _build -o -name .venv \
       -o -name .git -o -name vendor -o -name dist -o -name build \
       -o -name .next -o -name .elixir_ls -o -name cover \) -prune \
    -o -type f -name "$1" -print 2>/dev/null
}

say "=== session-setup ($root) ==="

# ---- Elixir (mix.lock present → umbrella root or standalone project) ----
if command -v mix >/dev/null 2>&1; then
  find_roots mix.lock | while IFS= read -r lf; do
    d=$(dirname "$lf"); [ -f "$d/mix.exs" ] || continue
    needs "$lf" "$d/deps" && run_in "$d" mix deps.get
    run_in "$d" mix compile
  done
fi

# ---- Node (one block per package manager, keyed by its lockfile) ----
if command -v npm >/dev/null 2>&1; then
  find_roots package-lock.json | while IFS= read -r lf; do
    d=$(dirname "$lf"); [ -f "$d/package.json" ] || continue
    needs "$lf" "$d/node_modules" && run_in "$d" npm install
    run_in "$d" npm run typecheck --if-present
  done
fi
if command -v yarn >/dev/null 2>&1; then
  find_roots yarn.lock | while IFS= read -r lf; do
    d=$(dirname "$lf"); [ -f "$d/package.json" ] || continue
    needs "$lf" "$d/node_modules" && run_in "$d" yarn install
  done
fi
if command -v pnpm >/dev/null 2>&1; then
  find_roots pnpm-lock.yaml | while IFS= read -r lf; do
    d=$(dirname "$lf"); [ -f "$d/package.json" ] || continue
    needs "$lf" "$d/node_modules" && run_in "$d" pnpm install
  done
fi

# ---- Python ----
if command -v uv >/dev/null 2>&1; then
  find_roots uv.lock | while IFS= read -r lf; do
    d=$(dirname "$lf")
    needs "$lf" "$d/.venv" && run_in "$d" uv sync
  done
fi
if command -v poetry >/dev/null 2>&1; then
  find_roots poetry.lock | while IFS= read -r lf; do
    d=$(dirname "$lf"); [ -f "$d/pyproject.toml" ] || continue
    run_in "$d" poetry install
  done
fi

# ---- Fallbacks: a root manifest with no lockfile yet (fresh project) ----
if [ -f mix.exs ] && [ ! -d deps ] && command -v mix >/dev/null 2>&1; then
  run_in "$root" mix deps.get; run_in "$root" mix compile
fi
if [ -f package.json ] && [ ! -d node_modules ] \
   && [ ! -f package-lock.json ] && [ ! -f yarn.lock ] && [ ! -f pnpm-lock.yaml ] \
   && command -v npm >/dev/null 2>&1; then
  run_in "$root" npm install
fi
if [ -f pyproject.toml ] && [ ! -d .venv ] && [ ! -f uv.lock ] \
   && command -v uv >/dev/null 2>&1; then
  run_in "$root" uv sync
fi

say "=== session-setup done ==="
exit 0
