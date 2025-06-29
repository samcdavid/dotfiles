# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages development environment configurations across multiple tools and languages. The repository uses a symlink-based approach to deploy configurations to their expected locations. The dotfiles are managed through the [rcm suite](https://github.com/thoughtbot/rcm) of programs.

- rcup is the main program. It is used to install and update dotfiles, with support for tags, host-specific files, and multiple source directories.
- rcdn is the opposite of rcup.
- mkrc is for introducing a dotfile into your dotfiles directory, with support for tags and multiple source directories.
- lsrc shows you all your dotfiles and where they would be symlinked to. It is used by rcup but is provided for your own use, too.

## Architecture and Structure

### Configuration Management

- **Primary Shell**: Fish shell with extensive custom functions and completions
- **Terminal Multiplexer**: tmux with custom key bindings and plugin management
- **Editor**: Neovim with LazyVim framework configuration
- **Version Control**: Git with GPG signing, custom templates, and global ignore patterns

### Key Components

- `config/` - Contains application-specific configurations
  - `fish/` - Fish shell configuration with 30+ custom functions
  - `omf/` - Oh My Fish framework configuration
  - `nvim/` - Neovim configuration using LazyVim framework
- `tool-versions` - ASDF version manager tool definitions
- `gitconfig` - Git configuration with GPG signing enabled
- `tmux.conf` - Tmux configuration with vim-like key bindings

## Development Environment Setup

### Tool Version Management

The repository uses ASDF for managing multiple runtime versions:

- Node.js 22.2.0
- Ruby 2.7.1
- Python 3.13.5
- Erlang 28.0.1 / Elixir 1.18.4-otp-28
- Go 1.18.1
- Terraform 1.0.1
- PostgreSQL 16.3

### Setup Scripts

- `setup_asdf_node.js` - Configures Node.js GPG keyring for ASDF
- `setup_neo_vim.sh` - Creates symlinks for Neovim configuration

### Oh My Fish Packages

The configuration includes these OMF packages:
- `asdf` - ASDF version manager integration
- `bang-bang` - Command history expansion
- `colored-man-pages` - Colorized manual pages
- `config` - Configuration management
- `direnv` - Directory-based environment variables
- `fzf` - Fuzzy finder integration
- `iex` - Elixir IEx shell enhancements
- `mix` - Elixir Mix build tool integration
- `neovim` - Neovim editor integration
- `pbcopy` - macOS clipboard utilities
- `python` - Python development tools
- `rustup` - Rust toolchain manager
- `vi-mode` - Vi-style key bindings

### Neovim Configuration

Neovim is configured using the LazyVim framework with custom plugins:
- **Plugin Manager**: lazy.nvim
- **Base Framework**: LazyVim
- **Language Support**: Enhanced Elixir support via elixir-tools/elixir-ls
- **Editor Enhancements**: Telescope, Treesitter, todo-comments
- **Configuration Structure**: Modular Lua configuration in `config/nvim/lua/`

## Fish Shell Functions

The repository includes extensive Fish shell automation organized into categories:

### Git Workflow Functions

- `gs` - git status
- `gc` - git commit with GPG signing and verbose output
- `co` - git checkout
- `glog` - formatted git log with graph visualization
- `pull`/`push` - git pull/push shortcuts
- `shove` - force push with lease protection
- `end_feature` - automated feature branch cleanup (switches to main, pulls, deletes branch, prunes origin)
- `gr` - git rebase shortcut

### Development Environment Functions

- `server` - starts Phoenix development server (mix phx.server)
- `update_mix` - comprehensive Mix dependency update for dev/test environments
- `iexc` - Elixir interactive console
- `phoenixu` - Phoenix installer update
- `hexu` - Hex package manager update
- `rebaru` - Rebar3 update
- `cleanpyc` - removes Python compiled files
- `pap` - package management shortcut
- `vim` - Neovim alias

### Database Management Functions

- `pg_init`, `pg_start`, `pg_stop`, `pg_user` - PostgreSQL lifecycle management

### System and Docker Functions

- `mux`, `muxc`, `muxn`, `muxs` - tmux session management via tmuxinator
- `rm_docker`, `rmi_docker`, `stop_docker` - Docker container/image management
- `myip` - retrieve external IP address
- `tf` - Terraform shortcut
- `ll` - enhanced directory listing

## Development Focus Areas

This environment is optimized for:

- **Elixir/Phoenix web development** - Extensive Mix and Phoenix tooling
- **Git-based workflows** - Multiple git aliases and branch management automation
- **Containerized development** - Docker management utilities
- **Database-driven applications** - PostgreSQL tooling and management
- **Infrastructure as Code** - Terraform integration
- **Terminal-based workflows** - Heavy tmux and terminal multiplexing usage

## Configuration Philosophy

- **Minimal typing**: Most functions are 2-4 character aliases for common operations
- **Workflow automation**: Complex operations like feature branch cleanup are fully automated
- **Cross-tool consistency**: Unified theming and key bindings across terminal tools
- **Development-focused**: All customizations serve active development workflows rather than system administration
