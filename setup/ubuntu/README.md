# setup/ubuntu

Bootstraps a fresh Ubuntu machine (built and tested against 26.04 LTS,
GNOME/Wayland, with an NVIDIA GPU). Mirrors `setup/mac/install`'s shape —
see `../README.md` for how the two are kept in sync.

```bash
~/.dotfiles/setup/ubuntu/install
```

## What it does

1. `apt update && apt upgrade`
2. `repos.sh` — add every third-party apt repo/key the package list needs
   (GitHub CLI, Docker, PostgreSQL/PGDG, Google Cloud CLI, 1Password,
   VS Code, ngrok, NVIDIA CUDA, Claude Code, Claude Desktop)
3. Install every package in `Aptfile` (apt first, snap fallback if apt
   doesn't have it)
4. `manual-installs.sh` — everything with no apt package: asdf, uv, Codex
   CLI, Docker Desktop, the AWS Session Manager plugin, yarn (via
   corepack), NordVPN, AWS CLI, CircleCI CLI, Google Chrome, Neovim,
   fonts, and three GNOME Shell extensions
5. Symlink dotfiles via `rcup`
6. Authenticate with GitHub (`gh auth login`)
7. Generate an SSH key, register it with GNOME Keyring, upload it to GitHub
8. Set fish as the default shell
9. Install asdf plugins and language runtimes from `~/.tool-versions`
10. Install Oh My Fish + packages
11. Install Neovim plugins (headless Lazy sync)
12. Install tmux plugins via TPM (git-clone install to `~/.tmux/plugins/tpm`)
13. Generate a GPG key, configure commit signing, upload the key to GitHub
14. Run `preferences` — GNOME trackpad, F6 mic-mute hotkey, always-visible
    mic indicator
15. **Last, deliberately:** if an NVIDIA GPU is detected, install the driver
    (`ubuntu-drivers autoinstall`) and `cuda-toolkit` together — this is the
    only step in the whole run that needs a reboot to take effect, so it's
    placed dead last on purpose. Everything above it works before that reboot.

Each run logs to `~/laptop.log` (auto-numbered on re-runs), same as macOS.

## Files

```
install               # Bootstrap script
repos.sh              # Third-party apt repos/keys (runs before Aptfile)
Aptfile               # Plain apt package list
manual-installs.sh    # No-apt-package installs (git clone / GH release / official installer)
preferences            # GNOME trackpad, F6 mic-mute hotkey, mic indicator
```

## Manual / not-fully-unattended steps

- Set up 1Password before running `install`
- **Secure Boot:** if enabled, the NVIDIA driver install (the last step)
  prompts interactively for a MOK enrollment password
- **Reboot required** after the NVIDIA driver + CUDA step — the only reboot
  the whole script needs, which is why that step runs dead last
- `preferences` and the SSH-key-persistence step need an active graphical
  GNOME session (they talk to gnome-shell/GNOME Keyring over D-Bus) — don't
  run this over a plain SSH session
- **Pre-existing NVIDIA driver conflicts:** field-tested on a Dell machine
  that shipped with an older, differently-packaged driver already installed
  (the generic/unversioned `nvidia-dkms`/`libnvidia-cfg1` family) — installing
  Ubuntu's versioned `-595`-style family on top of it left two files
  double-claimed, and `dpkg` failed partway (no `Replaces:` between the two
  families). `install` now detects this (any nvidia package left "unpacked
  but not configured") and stops with instructions rather than telling you
  to reboot into a half-finished driver. Recovery, field-tested: `sudo apt
  --fix-broken install` alone isn't enough — it identifies the old
  unversioned packages as orphaned but doesn't remove them before retrying
  the unpack that conflicts with their files. `sudo apt autoremove -y`
  first (safe here: the `-595-open` family uses prebuilt kernel modules,
  not DKMS, so the orphaned `dkms` package genuinely isn't needed either),
  *then* `sudo apt --fix-broken install`. Confirm `nvidia-smi` still works
  before re-running `install` or touching MOK Manager again.
- NordVPN: after install, log in once with `nordvpn login`

## Notable decisions / departures from a literal cask→apt mapping

- **Docker Desktop sign-in needs `pass`, initialized, and a GPG key with an
  actual encryption subkey** — field-tested, three-layer bug: (1) `pass`
  (in Aptfile now) is what Docker Desktop's Linux credential storage uses
  internally, per Docker's own docs, but was never being initialized; (2)
  `install` generates a GPG key for commit signing, and `pass init` reuses
  it rather than asking for a separate one; (3) that generated key turned
  out to have *no encryption subkey at all* — `gpg --quick-generate-key
  ... default 0` is documented to include one for "default" usage, but
  didn't here, so `pass`/anything that encrypts to the key failed with
  "Unusable public key" until one was added explicitly. `install` now
  checks for an encryption-capable subkey and adds one if missing, and
  calls `pass init "$GPG_KEY_ID"` right after — don't assume the implicit
  "default" GPG usage did what it's documented to.
- **The original Brewfile→Aptfile mapping missed several formulae/casks
  entirely** (`watchman`, `yarn`, `cmake-docs`, `lolcat`, `session-manager-plugin`,
  and the `ghostty`/`claude` casks) — an oversight, not a deliberate drop
  like the ones listed further down. Caught by a full line-by-line
  cross-check against the Brewfile rather than spot-checking, after
  `ghostty` turned up missing in practice. If a tool from the Mac side
  ever seems to be silently absent on Ubuntu, that same full diff against
  `setup/mac/Brewfile` is the reliable way to check — don't assume a gap
  is deliberate just because it's undocumented.
- **Claude Code and Claude Desktop both come from Anthropic's own apt
  repos** (added in `repos.sh`), not npm/a one-off `.deb` — verified the
  claude-code key's fingerprint against Anthropic's published one before
  trusting it. This replaced an earlier `npm install -g @anthropic-ai/
  claude-code` in `manual-installs.sh` for the same reason Codex avoids
  npm: a signed, versioned apt package over a mutable install-time
  dependency tree. No global npm installs remain anywhere in this setup.
- **yarn comes from corepack** (bundled with Node), not `npm install -g
  yarn` — same no-global-npm-installs reasoning. `corepack enable` needs
  `sudo` (it symlinks shims into apt's root-owned bin dir), but
  `corepack prepare yarn@stable --activate` deliberately runs as the
  invoking user — under sudo it would cache the actual yarn package under
  `/root`, unreadable the moment you invoke `yarn` normally afterward.
- **Neovim** comes from a GitHub-release tarball (`manual-installs.sh`), not
  apt or a PPA — checked both official neovim-ppa options first: `stable`
  is abandoned (last upload 2022, v0.7.2, no 26.04 build), `unstable`
  tracks nightly git snapshots rather than tagged releases, neither is what
  we want. Since nothing then keeps it current automatically, re-run the
  `update_nvim` fish function whenever you want the latest tagged release —
  it's the unconditional version of the same install block.
- **`tool-versions` pins track current-latest, not what shipped with this
  repo originally** — checked live via `asdf latest <name>` rather than
  memory, since versions drift fast and get EOL'd. Re-check the same way
  next time these feel stale, rather than trusting whatever's already
  written here. `asdf latest python` includes free-threaded (`t`-suffixed)
  builds in its ordering — filter to the plain `X.Y.Z` form for the
  standard interpreter.
- **Ruby/Python/Erlang build-dependency dev packages are in Aptfile even
  though nothing in the Brewfile has an equivalent** — `ruby-build`/
  `python-build`/`kerl` compile these from source, and macOS's build
  toolchain (Xcode Command Line Tools) already carries the equivalent libs
  implicitly. Field-tested without them: `ruby-build` hard-fails on
  readline/psych (missing `libreadline-dev`/`libyaml-dev`), and
  `python-build` *silently* produces a Python with no bz2/readline/
  sqlite3/tkinter stdlib modules — no error, just a degraded interpreter —
  without `libbz2-dev`/`libreadline-dev`/`libsqlite3-dev`/`tk-dev`.
- **Casks dropped entirely, no Linux equivalent sought:** `altair-graphql-client`,
  `insomnia`, `loom`, `macdown`, `muzzle`, `notion`, `protonvpn`, `tuple`
  (per explicit request), plus `hammerspoon`, `rectangle`,
  `font-menlo-for-powerline`, `font-sf-mono-for-powerline`, `gpg-suite`,
  `chromedriver`, `linear-linear` (Mac-only tools/fonts with no real Linux
  port — see git history if you want the original reasoning per item).
- **Docker Desktop**, not Engine-only — installed via the official `.deb`
  after Docker's apt repo is registered (needed as a dependency even though
  Desktop bundles its own engine in a VM). `gnome-shell-extension-appindicator`
  is installed alongside it for the tray icon.
- **PostgreSQL tracks latest stable major**, no version pin — the PGDG
  repo's unversioned `postgresql` package always resolves to current latest,
  so there's no version string to bump over time. (Mac's Brewfile was
  changed to match: `postgresql`, not `postgresql@17`.)
- **NVIDIA CUDA**: driver comes from Ubuntu's own `ubuntu-drivers` (stays in
  sync with the running kernel); only `cuda-toolkit` comes from NVIDIA's
  repo, deliberately *not* the `cuda` metapackage, which also pulls NVIDIA's
  own driver build and can conflict with the Ubuntu-managed one. Both are
  installed together as the very last step of `install` — not from
  `Aptfile` — so the whole script needs exactly one reboot, at the end,
  instead of one stranded mid-run. `repos.sh` still adds the cuda-keyring
  repo/key early; that part has no reboot implication.
- **Codex CLI is a verified GH-release binary, not `npm install`** — avoids
  npm's mutable, transitively-resolved dependency tree. Downloads the
  `-package-` asset (the one covered by `codex-package_SHA256SUMS`) and
  verifies the checksum before installing. Claude Code stays on npm — that
  concern was raised specifically about Codex, not extended here.
- **Mic mute + status indicator are two separate GNOME Shell extensions**,
  not a single hand-rolled `wpctl` keybinding: [Mute All Microphones](https://extensions.gnome.org/extension/10247/mute-all-microphones/)
  owns the F6 hotkey (and takes over GNOME's built-in mic-mute binding so
  there's only one handler), [Quick Settings Audio Panel](https://extensions.gnome.org/extension/5940/quick-settings-audio-panel/)
  forces GNOME's own mic slider/icon to stay visible in Quick Settings
  instead of only appearing while recording — so the "indicator" reuses
  GNOME's native icon/state rather than adding a second, possibly
  inconsistent one. Exact gsettings schema/key names were captured live
  against `gnome-shell --version` at the time of writing; if a future GNOME
  bumps the extensions past compatibility, re-check
  `https://extensions.gnome.org/extension-query/?search=<name>&shell_version=<N>`
  for the current pk.
- **Extension-local gsettings schemas need `GSETTINGS_SCHEMA_DIR` set explicitly**
  — field-tested, and non-obvious enough to be worth flagging clearly:
  `gsettings` only searches the standard system/user glib schema paths, not
  `~/.local/share/gnome-shell/extensions/<uuid>/schemas/`. GNOME Shell
  itself resolves extension-local schemas through a different internal API
  when the extension's own code calls `this.getSettings()`, so this bites
  you specifically when scripting `gsettings set`/`get` from *outside* the
  extension (exactly what `preferences` does) — you'll get "No such
  schema" even with the extension confirmed `Enabled`/`ACTIVE` via
  `gnome-extensions info` and its schema already compiled. `preferences`'
  `configure_extension` helper sets `GSETTINGS_SCHEMA_DIR` per-extension
  before each call; do the same for any new extension-backed setting added
  here.
- **Two separate, independent reasons an extension's `gsettings` call can
  fail right after `install` finishes, both handled by `preferences`:**
  (1) GNOME Shell not seeing a just-installed extension until next login
  (the Wayland limitation above), and (2) the `GSETTINGS_SCHEMA_DIR` issue
  just above — these look identical ("No such schema") but need different
  fixes, and it's easy to patch one and assume the whole thing's resolved.
- **Tiling** (Rectangle equivalent): [Tiling Shell](https://extensions.gnome.org/extension/7065/tiling-shell/),
  installed and enabled by `manual-installs.sh`. Its keybindings are
  gsettings-backed (`org.gnome.shell.extensions.tilingshell`) but the exact
  per-direction key names weren't captured before writing this — run
  `gnome-extensions prefs tilingshell@ferrarodomenico.com` to customize
  interactively, or `GSETTINGS_SCHEMA_DIR=~/.local/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com/schemas gsettings list-keys org.gnome.shell.extensions.tilingshell`
  to script it once you've set them the way you want.
- **Chromedriver** intentionally has no system-wide install — Ubuntu's
  Chromium is snap-only, which chromedriver packaging doesn't play well
  with. Per-project `webdriver-manager` (matches the installed Chrome
  version automatically) is the modern replacement for a pinned system
  install here.
- **`~/.gitconfig.local`** — same mechanism as Mac, see `setup/mac/README.md`.
  Carries `user.email`, `user.signingkey`, and `credential.helper`.
  `credential.helper` defaults to git's built-in `cache` (1hr, in-memory,
  zero extra deps). `git-credential-libsecret` is a more persistent
  upgrade if you want it, not set up here.
- **No more directory-based work/personal git identity** — `gitconfig-work`
  and `gitconfig-personal` (and the `includeIf "gitdir:..."` blocks that
  pulled them in) are gone; a single `user.email` in `~/.gitconfig.local`
  covers it. Edit that file by hand if a machine ever needs a different
  email.
- **No `~/.laptop.local` local-overrides hook** — deliberate, for
  cross-machine consistency; see `../README.md`.
