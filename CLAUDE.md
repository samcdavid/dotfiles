# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles managed through the [rcm suite](https://github.com/thoughtbot/rcm). Supports both Intel (`/usr/local`) and Apple Silicon (`/opt/homebrew`) Macs.

- `rcup` creates symlinks from `~/.dotfiles/` to `~/`
- `rcdn` removes symlinks
- `mkrc` adds a new dotfile to the repo
- `lsrc` lists all managed symlinks
- Files under `config/` are symlinked to `~/.config/`

## Architecture

- **Shell**: Fish with Oh My Fish framework
- **Editor**: Neovim with LazyVim framework
- **Terminal**: Ghostty + tmux with TPM plugin manager
- **Version Manager**: asdf
- **VCS**: Git with GPG signing

## Key Components

- `config/fish/` — Fish shell config with 32 custom functions in `functions/`
- `config/ghostty/` — Ghostty terminal config (theme, font)
- `config/nvim/` — Neovim LazyVim config (modular Lua plugins in `lua/plugins/`)
- `config/omf/` — Oh My Fish packages and theme
- `config/tmuxinator/` — Tmuxinator project session configs
- `tmux.conf` — tmux config with portable Intel/Apple Silicon path detection via `if-shell`
- `tool-versions` — asdf runtime version pins
- `gitconfig` — Git config with GPG signing enabled
- `psqlrc` — PostgreSQL client config (custom prompts, timing, unicode)
- `direnvrc` — Custom direnv layouts (anaconda, poetry)
- `envrc` — Environment variables (symlinked to `~/.envrc`)

## Oh My Fish Packages

bang-bang, colored-man-pages, config, direnv, fzf, iex, mix, neovim, python, rustup, vi-mode

## Fish Functions by Category

### Git
`gs`, `gc`, `co`, `gr`, `glog`, `pull`, `push`, `shove`, `pap`, `end_feature`

### Elixir/Phoenix
`server`, `iexc`, `update_mix`, `hexu`, `rebaru`, `phoenixu`

### PostgreSQL
`pg_init`, `pg_start`, `pg_stop`, `pg_user`

### Docker
`stop_docker`, `rm_docker`, `rmi_docker`

### Tmux
`mux`, `muxc`, `muxn`, `muxs`

### System
`ll`, `myip`, `vim`, `tf`, `cleanpyc`

## Portability

The tmux.conf uses `if-shell` to detect architecture and set correct paths for fish and TPM. The fish config.fish uses generic asdf shim detection (`$HOME/.asdf/shims`) that works on both architectures. The psqlrc uses bare `nvim` (in PATH) rather than an absolute path.
