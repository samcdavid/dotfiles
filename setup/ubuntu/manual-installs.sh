#!/bin/bash

# Everything with no reliable apt package: git-clone/GH-release/official
# installer scripts. Runs after Aptfile packages, before the critical
# dependency check (asdf is checked there, so it must land here).

set -e

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

mkdir -p "$HOME/.local/bin"

# --- asdf (GH-release Go binary — current asdf, v0.16+, is no longer the
#     old git-clone-a-shell-script install; that method leaves no standalone
#     `asdf` executable until asdf.sh is sourced, which breaks the critical-
#     deps check below since nothing sources it until much later) -----------
if ! command -v asdf >/dev/null; then
  fancy_echo "Installing asdf..."
  ASDF_TAG=$(curl -fsSL https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/${ASDF_TAG}/asdf-${ASDF_TAG}-linux-amd64.tar.gz" \
    | tar -xz -C "$HOME/.local/bin" asdf
fi

# --- uv (astral) ----------------------------------------------------------
if ! command -v uv >/dev/null; then
  fancy_echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Claude Code and Claude Desktop are both installed from Aptfile now —
# Anthropic has first-party apt repos for both (added in repos.sh), which
# is strictly better than a global npm install for the same reason Codex
# avoids npm below: a signed apt package over a mutable dependency tree.

# --- Codex CLI — GH-release binary + checksum verify, NOT npm ------------
# Deliberately not `npm install -g @openai/codex`: pulling a single verified
# binary release avoids npm's mutable, transitively-resolved install-time
# dependency tree. Uses the checksummed "-package-" asset (the plain
# codex-<target>.tar.gz asset isn't covered by codex-package_SHA256SUMS).
if ! command -v codex >/dev/null; then
  fancy_echo "Installing Codex CLI..."
  CODEX_TAG=$(curl -fsSL https://api.github.com/repos/openai/codex/releases/latest | jq -r .tag_name)
  CODEX_ASSET="codex-package-x86_64-unknown-linux-musl.tar.gz"
  CODEX_TMP="$(mktemp -d)"
  # Downloaded under its real asset name — codex-package_SHA256SUMS checks
  # filenames literally, so renaming this (as a prior version of this script
  # did, to "codex.tar.gz") makes sha256sum -c report a false "no such file".
  curl -fsSL -o "$CODEX_TMP/$CODEX_ASSET" \
    "https://github.com/openai/codex/releases/download/${CODEX_TAG}/${CODEX_ASSET}"
  curl -fsSL -o "$CODEX_TMP/SHA256SUMS" \
    "https://github.com/openai/codex/releases/download/${CODEX_TAG}/codex-package_SHA256SUMS"
  (cd "$CODEX_TMP" && grep "$CODEX_ASSET\$" SHA256SUMS | sha256sum -c -)
  tar -xzf "$CODEX_TMP/$CODEX_ASSET" -C "$CODEX_TMP"
  CODEX_BIN="$(find "$CODEX_TMP" -type f -name 'codex' | head -1)"
  if [ -z "$CODEX_BIN" ]; then
    fancy_echo "Warning: could not locate the codex binary inside the release archive."
  else
    install -m 0755 "$CODEX_BIN" "$HOME/.local/bin/codex"
    fancy_echo "Codex CLI installed to ~/.local/bin/codex."
  fi
  rm -rf "$CODEX_TMP"
fi

# --- Docker Desktop -------------------------------------------------------
if ! command -v docker-desktop >/dev/null 2>&1 && [ ! -d /opt/docker-desktop ]; then
  fancy_echo "Installing Docker Desktop..."
  curl -fsSL -o /tmp/docker-desktop-amd64.deb \
    https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
  sudo apt install -y /tmp/docker-desktop-amd64.deb
  rm /tmp/docker-desktop-amd64.deb
fi

# Installing the package alone doesn't add the invoking user to the `docker`
# group — field-tested: `docker ps` gets a flat "permission denied" without
# this. Group membership only takes effect in a new login session (`newgrp
# docker` works for the current shell without a full relogin).
if ! groups "$USER" | grep -qw docker; then
  fancy_echo "Adding $USER to the docker group (takes effect next login, or run: newgrp docker)..."
  sudo usermod -aG docker "$USER"
fi

# --- NordVPN ----------------------------------------------------------
if ! command -v nordvpn >/dev/null; then
  fancy_echo "Installing NordVPN..."
  # -n = non-interactive: without it, the installer's own internal
  # `apt-get install` prompts for confirmation, and since stdin isn't a
  # real terminal here (curl | sh), it reads EOF and aborts instead.
  curl -fsSL https://downloads.nordcdn.com/apps/linux/install.sh | sh -s -- -n
  fancy_echo "Add yourself to the nordvpn group and log back in, then run: nordvpn login"
fi

# --- AWS CLI (official installer — apt's version lags) -------------------
if ! command -v aws >/dev/null; then
  fancy_echo "Installing AWS CLI..."
  AWS_TMP="$(mktemp -d)"
  curl -fsSL -o "$AWS_TMP/awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  unzip -q "$AWS_TMP/awscliv2.zip" -d "$AWS_TMP"
  sudo "$AWS_TMP/aws/install"
  rm -rf "$AWS_TMP"
fi

# --- AWS Session Manager plugin (for `aws ssm start-session`) -------------
if ! command -v session-manager-plugin >/dev/null; then
  fancy_echo "Installing AWS Session Manager plugin..."
  SSM_TMP="$(mktemp -d)"
  curl -fsSL -o "$SSM_TMP/session-manager-plugin.deb" \
    "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
  sudo dpkg -i "$SSM_TMP/session-manager-plugin.deb"
  rm -rf "$SSM_TMP"
fi

# --- yarn (via corepack, bundled with Node — no global npm install) -------
if ! command -v yarn >/dev/null; then
  fancy_echo "Installing yarn..."
  # `enable` needs sudo — it symlinks shims into apt's root-owned bin dir.
  # `prepare --activate` deliberately runs as the invoking user, not sudo:
  # it fetches/caches the actual yarn package into the user's own cache
  # dir, which a sudo'd run would put under /root instead — unreadable
  # the moment you actually invoke `yarn` afterward.
  sudo corepack enable
  corepack prepare yarn@stable --activate
fi

# --- CircleCI CLI -----------------------------------------------------
if ! command -v circleci >/dev/null; then
  fancy_echo "Installing CircleCI CLI..."
  curl -fsSL https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh \
    | sudo bash
fi

# --- Google Chrome (Ubuntu's Chromium is snap-only; chromedriver is left
#     to per-project webdriver-manager rather than a pinned system install) -
if ! command -v google-chrome >/dev/null; then
  fancy_echo "Installing Google Chrome..."
  curl -fsSL -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y /tmp/chrome.deb
  rm /tmp/chrome.deb
fi

# --- Neovim (apt's version lags LazyVim's requirements — field-tested: it
#     was missing from this script entirely, breaking the Lazy-sync step
#     later in install with a plain "nvim: command not found") -------------
# A relocatable bin/lib/share tree, not a standalone binary — kept together
# under ~/.local/nvim and symlinked, rather than pulling bin/nvim out alone.
# This block only ever installs once (guarded below) — no apt/PPA to defer
# updates to, so re-run the `update_nvim` fish function whenever you want
# the latest release; it's this same logic, unconditional.
if ! command -v nvim >/dev/null; then
  fancy_echo "Installing Neovim..."
  NVIM_TAG=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r .tag_name)
  rm -rf "$HOME/.local/nvim"
  mkdir -p "$HOME/.local/nvim"
  curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/nvim-linux-x86_64.tar.gz" \
    | tar -xz --strip-components=1 -C "$HOME/.local/nvim"
  ln -sf "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
fi

# --- chroma (syntax highlighter CLI) --------------------------------------
if ! command -v chroma >/dev/null; then
  fancy_echo "Installing chroma..."
  CHROMA_TAG=$(curl -fsSL https://api.github.com/repos/alecthomas/chroma/releases/latest | jq -r .tag_name)
  curl -fsSL "https://github.com/alecthomas/chroma/releases/download/${CHROMA_TAG}/chroma-${CHROMA_TAG#v}-linux-amd64.tar.gz" \
    | tar -xz -C "$HOME/.local/bin" chroma
fi

# --- websocat (not in apt or snap on 26.04, field-tested) -----------------
if ! command -v websocat >/dev/null; then
  fancy_echo "Installing websocat..."
  curl -fsSL -o "$HOME/.local/bin/websocat" \
    "https://github.com/vi/websocat/releases/latest/download/websocat.x86_64-unknown-linux-musl"
  chmod +x "$HOME/.local/bin/websocat"
fi

# --- super (brimdata) ------------------------------------------------------
# The Mac Brewfile's tap (brimdata/tap/zq) is the pre-rebrand name — the
# project (and its GitHub repo) has since moved: brimdata/zed -> brimdata/super,
# and the shipped binary is now literally named `super`, not `zq`. Confirmed
# live (repo lookup 301s from the old name/repo ID to the new one).
if ! command -v super >/dev/null; then
  fancy_echo "Installing super (brimdata)..."
  SUPER_TAG=$(curl -fsSL https://api.github.com/repos/brimdata/super/releases/latest | jq -r .tag_name)
  SUPER_TMP="$(mktemp -d)"
  curl -fsSL "https://github.com/brimdata/super/releases/download/${SUPER_TAG}/super-${SUPER_TAG}.linux-amd64.tar.gz" \
    | tar -xz -C "$SUPER_TMP"
  install -m 0755 "$SUPER_TMP/super" "$HOME/.local/bin/super"
  rm -rf "$SUPER_TMP"
fi

# --- tmuxinator (gem, decoupled from asdf's ruby — mirrors how the Mac
#     Brewfile installs it independently of asdf too) ---------------------
if ! command -v tmuxinator >/dev/null; then
  fancy_echo "Installing tmuxinator..."
  sudo gem install tmuxinator
fi

# --- Fonts (Hack, JetBrains Mono, JetBrains Mono Nerd Font) ---------------
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [ ! -f "$FONT_DIR/Hack Regular Nerd Font Complete.ttf" ]; then
  fancy_echo "Installing fonts..."
  FONT_TMP="$(mktemp -d)"
  for font in Hack JetBrainsMono; do
    curl -fsSL -o "$FONT_TMP/$font.zip" \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
    unzip -q -o "$FONT_TMP/$font.zip" -d "$FONT_DIR" '*.ttf'
  done
  rm -rf "$FONT_TMP"
  fc-cache -f "$FONT_DIR"
fi

# --- GNOME Shell extensions -----------------------------------------------
# pk values are per-shell-version release ids from extensions.gnome.org;
# re-check https://extensions.gnome.org/extension-query/?search=<name>&shell_version=<N>
# if `gnome-shell --version` has moved past what these were captured against.
install_gnome_extension() {
  local uuid="$1" pk="$2"
  if gnome-extensions list 2>/dev/null | grep -Fq "$uuid"; then
    return
  fi
  fancy_echo "Installing GNOME extension $uuid..."
  local zip="$(mktemp --suffix=.zip)"
  curl -fsSL -o "$zip" \
    "https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_tag=${pk}"
  gnome-extensions install --force "$zip"
  gnome-extensions enable "$uuid" || fancy_echo "  Enable manually after logging back in: gnome-extensions enable $uuid"
  rm "$zip"
}

# Global F6 mic-mute hotkey + native GNOME mute OSD, replacing GNOME's
# default mic-mute binding.
install_gnome_extension "mute-all-mics@VitalyOstanin" 71986
# Keeps GNOME's own mic slider/icon permanently visible in Quick Settings
# next to volume/wifi, instead of only while actively recording.
install_gnome_extension "quick-settings-audio-panel@rayzeq.github.io" 73470
# Rectangle-style tiling with configurable keyboard shortcuts.
install_gnome_extension "tilingshell@ferrarodomenico.com" 70233
