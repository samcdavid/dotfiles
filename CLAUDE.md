# CLAUDE.md

This file provides guidance to Claude Code and Codex when working in this repository.

## Repository Overview

Personal dotfiles managed through the [rcm suite](https://github.com/thoughtbot/rcm). Supports both Intel (`/usr/local`) and Apple Silicon (`/opt/homebrew`) Macs.

- `rcup` creates symlinks from this repo into `$HOME`.
- `rcdn` removes symlinks.
- `mkrc` adds a new dotfile to the repo.
- `lsrc` lists managed symlinks.
- Files under `config/` are symlinked into `~/.config/`.

## Architecture

- **Shell:** Fish with Oh My Fish.
- **Editor:** Neovim with LazyVim.
- **Terminal:** Ghostty and tmux with TPM.
- **Version Manager:** asdf.
- **VCS:** Git with GPG signing.

## Key Components

- `config/fish/` - Fish shell config with custom functions in `functions/`.
- `config/ghostty/` - Ghostty terminal config.
- `config/nvim/` - Neovim LazyVim config.
- `config/omf/` - Oh My Fish packages and theme.
- `config/tmuxinator/` - Tmuxinator project session configs.
- `tmux.conf` - tmux config with portable Intel/Apple Silicon path detection.
- `tool-versions` - asdf runtime version pins.
- `gitconfig` - Git config with GPG signing enabled.
- `psqlrc` - PostgreSQL client config.
- `direnvrc` - Custom direnv layouts.
- `envrc` - Environment variables, symlinked to `~/.envrc`.

## Claude and Codex Skills/Agents

- Canonical skill definitions live in `claude/skills/`.
- Canonical Claude agent definitions live in `claude/agents/`.
- Codex-visible personal skills are exposed through `agents/skills/`; each entry symlinks back to `claude/skills/<name>`.
- Shared reusable rules live in `claude/rules/`; `agents/rules` symlinks back to that directory.
- Codex custom agents are generated TOML files under `codex/agents/` from `claude/agents/*.md`.
- RCM links the runtime directories listed in `rcrc`: `claude/agents`, `claude/rules`, `agents/skills`, `agents/rules`, and `codex/agents`.
- The repo-local `AGENTS.md` symlink points to this file for Codex-style project guidance, but `AGENTS.md` is excluded from RCM and should not be linked into `$HOME`.

When changing skills or agents:

1. Edit canonical files under `claude/skills/`, `claude/agents/`, or `claude/rules/`.
2. If a new skill is added, add `agents/skills/<name> -> ../../claude/skills/<name>` so Codex can discover it.
3. If Claude agents changed, run `scripts/sync-codex-agents` to regenerate `codex/agents/*.toml`.
4. Keep longer skill instructions in `references/protocol-index.md` and targeted files under `references/protocol-sections/`; do not reintroduce monolithic `full-protocol.md` files.
5. Run `scripts/check-agent-drift` before finishing larger instruction changes. It checks symlinks, generated Codex agents, critical-agent reasoning effort, home links, and entrypoint budgets.
6. Run `rcup` after changing RCM-managed directories or `rcrc`, then verify the relevant `$HOME` symlinks.

Automation:

- `.githooks/pre-commit` runs `scripts/check-agent-drift`; this repo configures `core.hooksPath=.githooks`.
- Review-critical generated Codex agents (`adversarial-debate`, `security-reviewer`, `perf-reviewer`, `arch-reviewer`) use `model_reasoning_effort = "xhigh"` in `codex/agents/*.toml`; `my-review` orchestration stays on the standard model.

## Oh My Fish Packages

`bang-bang`, `colored-man-pages`, `config`, `direnv`, `fzf`, `iex`, `mix`, `neovim`, `python`, `rustup`, `vi-mode`.

## Fish Functions by Category

- **Git:** `gs`, `gc`, `co`, `gr`, `glog`, `pull`, `push`, `shove`, `pap`, `end_feature`.
- **Elixir/Phoenix:** `server`, `iexc`, `update_mix`, `hexu`, `rebaru`, `phoenixu`.
- **PostgreSQL:** `pg_init`, `pg_start`, `pg_stop`, `pg_user`.
- **Docker:** `stop_docker`, `rm_docker`, `rmi_docker`.
- **Tmux:** `mux`, `muxc`, `muxn`, `muxs`.
- **System:** `ll`, `myip`, `vim`, `tf`, `cleanpyc`.

## Portability

`tmux.conf` uses `if-shell` to detect architecture and set the correct Fish and TPM paths. Fish config uses generic asdf shim detection (`$HOME/.asdf/shims`) that works on both architectures. `psqlrc` uses bare `nvim` from `PATH` rather than an absolute path.
