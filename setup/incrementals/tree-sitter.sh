#!/bin/bash

# Installs tree-sitter-cli and sets up language grammars. Safe to re-run —
# every step is guarded — and works unmodified on both mac and Ubuntu: the
# only OS-specific part is which package manager installs the CLI itself,
# everything after that (config, grammar clones, the fish shim) is the same
# either way. Called from setup/mac/install and setup/ubuntu/install, and
# also meant to be run standalone on an already-set-up machine that just
# needs this one piece (`~/.dotfiles/setup/incrementals/tree-sitter.sh`).

set -e

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

# --- Install the CLI ---------------------------------------------------
# apt/brew's package is only the parser/query engine — it ships with zero
# language grammars, so `tree-sitter parse` fails with "No language found"
# on every file until the grammars below are in place.
if command -v tree-sitter >/dev/null 2>&1; then
  : # already installed
elif command -v brew >/dev/null 2>&1; then
  fancy_echo "Installing tree-sitter via Homebrew..."
  # brew's "tree-sitter" formula is library-only (libtree-sitter) as of
  # tree-sitter 0.25+; the CLI is the separate "tree-sitter-cli" formula.
  brew install tree-sitter-cli
elif command -v apt >/dev/null 2>&1; then
  fancy_echo "Installing tree-sitter-cli via apt..."
  sudo apt install -y tree-sitter-cli
else
  fancy_echo "Error: neither brew nor apt found — install tree-sitter manually."
  exit 1
fi

for dep in jq git; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    fancy_echo "Error: '$dep' is required but not installed."
    exit 1
  fi
done

# --- Config + dedicated grammar directory -------------------------------
# Grammars live in their own directory rather than ~/github so they don't
# mix with real project checkouts; it's added to parser-directories below.
fancy_echo "Configuring tree-sitter..."
if [ ! -f "$HOME/.config/tree-sitter/config.json" ]; then
  tree-sitter init-config
fi
GRAMMAR_DIR="$HOME/.local/share/tree-sitter/grammars"
mkdir -p "$GRAMMAR_DIR"
TS_CONFIG="$HOME/.config/tree-sitter/config.json"
if ! jq -e --arg d "$GRAMMAR_DIR" '.["parser-directories"] | index($d)' "$TS_CONFIG" >/dev/null; then
  jq --arg d "$GRAMMAR_DIR" '.["parser-directories"] |= [$d] + .' "$TS_CONFIG" > "$TS_CONFIG.tmp"
  mv "$TS_CONFIG.tmp" "$TS_CONFIG"
fi

# --- Grammars ------------------------------------------------------------
fancy_echo "Installing tree-sitter grammars..."
for repo in \
  tree-sitter/tree-sitter-python \
  tree-sitter/tree-sitter-javascript \
  tree-sitter/tree-sitter-typescript \
  tree-sitter/tree-sitter-ruby \
  tree-sitter/tree-sitter-go \
  tree-sitter/tree-sitter-bash \
  tree-sitter/tree-sitter-json \
  tree-sitter-grammars/tree-sitter-yaml \
  tree-sitter-grammars/tree-sitter-lua \
  ram02z/tree-sitter-fish \
  elixir-lang/tree-sitter-elixir \
  ; do
  name="$(basename "$repo")"
  dest="$GRAMMAR_DIR/$name"
  [ -d "$dest" ] && continue
  git clone --depth 1 "https://github.com/$repo.git" "$dest"
done

# tree-sitter-fish predates the CLI's tree-sitter.json manifest convention
# and has no "tree-sitter" key in package.json either, so the CLI can't
# auto-discover its scope/file-type without this shim (field-tested on
# tree-sitter-cli 0.25.9 — dump-languages otherwise lists it with a blank
# scope and no file_types, and `tree-sitter parse *.fish` fails).
FISH_GRAMMAR="$GRAMMAR_DIR/tree-sitter-fish"
if [ -d "$FISH_GRAMMAR" ] && [ ! -f "$FISH_GRAMMAR/tree-sitter.json" ]; then
  cat > "$FISH_GRAMMAR/tree-sitter.json" <<'EOF'
{
  "grammars": [
    {
      "name": "fish",
      "camelcase": "Fish",
      "scope": "source.fish",
      "path": ".",
      "file-types": ["fish"],
      "highlights": "queries/highlights.scm",
      "injection-regex": "^fish$"
    }
  ],
  "metadata": {
    "version": "3.7.0",
    "license": "MIT",
    "description": "Fish grammar for tree-sitter",
    "links": { "repository": "https://github.com/ram02z/tree-sitter-fish" }
  }
}
EOF
fi

fancy_echo "tree-sitter ready: %s languages configured" "$(tree-sitter dump-languages 2>&1 | grep -c '^scope:')"
