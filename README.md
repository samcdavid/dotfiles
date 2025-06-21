# Dotfiles

A personal dotfiles repository that manages development environment configurations across multiple tools and languages using a symlink-based approach with the [rcm suite](https://github.com/thoughtbot/rcm).

## Quick Start

```bash
# Install dotfiles
rcup

# List what would be symlinked
lsrc

# Remove dotfiles
rcdn
```

## Environment

- **Shell**: Fish with 30+ custom functions
- **Editor**: Neovim with LazyVim framework
- **Terminal**: tmux with vim-like bindings
- **Version Manager**: ASDF with multiple runtimes
- **VCS**: Git with GPG signing

## Key Features

### Development Tools
- Node.js 22.2.0, Ruby 2.7.1, Python 3.13.5
- Elixir 1.18.4/Erlang 28.0.1, Go 1.18.1
- PostgreSQL 16.3, Terraform 1.0.1

### Fish Functions
- `gs`, `gc`, `co` - Git shortcuts
- `end_feature` - Automated branch cleanup
- `server` - Phoenix dev server
- `pg_*` - PostgreSQL management
- `mux*` - Tmux session management

### Neovim Plugins
- LazyVim framework
- Enhanced Elixir support
- Telescope, Treesitter
- Todo comments

## Structure

```
config/
├── fish/     # Shell configuration
├── nvim/     # Neovim LazyVim setup
└── omf/      # Oh My Fish packages
gitconfig     # Git with GPG signing
tmux.conf     # Terminal multiplexer
tool-versions # ASDF runtime versions
```

## Setup

1. Clone repository
2. Install rcm: `brew install rcm`
3. Run `rcup` to create symlinks
4. Install ASDF and tools: `asdf install`
5. Setup Neovim: `./setup_neo_vim.sh`

Optimized for Elixir/Phoenix development with terminal-based workflows.