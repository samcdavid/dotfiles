# setup/mac

Bootstraps a fresh macOS machine. Works on both Intel (`/usr/local`) and
Apple Silicon (`/opt/homebrew`) — `install` detects the prefix from `uname -m`.

```bash
~/.dotfiles/setup/mac/install
```

## What it does

1. Install Homebrew and everything in `Brewfile` (formulae + casks)
2. Symlink dotfiles via `rcup`
3. Authenticate with GitHub (`gh auth login`)
4. Generate an SSH key, add it to the macOS Keychain, upload it to GitHub
5. Set fish as the default shell
6. Install asdf plugins and language runtimes from `~/.tool-versions`
7. Install Oh My Fish + packages
8. Install Neovim plugins (headless Lazy sync)
9. Install tmux plugins via TPM (git-clone install to `~/.tmux/plugins/tpm`)
10. Generate a GPG key, configure commit signing, upload the key to GitHub
11. Run `preferences` — Dock/Finder/trackpad defaults + text-replacement import

Each run logs to `~/laptop.log` (auto-numbered on re-runs).

## Files

```
install                   # Bootstrap script
preferences                # Dock, Finder, trackpad, text-replacement import
Brewfile                   # Homebrew formulae + casks
text-replacements.plist    # "Looks of disapproval" text replacements
```

## Manual steps

- Set up 1Password before running `install`

## Machine-local git config

`install` writes `user.email`, the GPG signing key, and the Keychain
credential helper to `~/.gitconfig.local` rather than into any tracked
gitconfig — see the `[include]` in the repo's `gitconfig`. Never `mkrc` that
file; it must stay untracked so each machine's independently-generated key
never lands in the repo. There's no more directory-based work/personal
identity switching (`gitconfig-work`/`gitconfig-personal` are gone) — edit
`~/.gitconfig.local` by hand if a machine ever needs a different email.
