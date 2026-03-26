# Dotfiles

Personal dotfiles and machine setup, managed with the [rcm suite](https://github.com/thoughtbot/rcm). Works on both Intel and Apple Silicon Macs.

## New Machine Setup

```bash
git clone https://github.com/samcdavid/dotfiles.git ~/.dotfiles && ~/.dotfiles/setup/mac
```

This single command will:

1. Install Homebrew and all packages/casks
2. Symlink dotfiles via rcm
3. Authenticate with GitHub
4. Generate SSH and GPG keys
5. Set Fish as default shell
6. Install asdf plugins and language runtimes
7. Install Oh My Fish packages
8. Install Neovim plugins
9. Install tmux plugins
10. Configure macOS preferences and text replacements

Each run is logged to `~/laptop.log` (auto-numbered on re-runs: `laptop1.log`, `laptop2.log`, etc.).

### Manual Steps

- Set up 1Password before running the script

## Environment

- **Shell**: Fish with Oh My Fish and 30+ custom functions
- **Editor**: Neovim with LazyVim framework
- **Terminal**: Ghostty + tmux with vim-like bindings and TPM
- **Version Manager**: asdf (Ruby, Node.js, Erlang, Elixir, Python, Go)
- **VCS**: Git with GPG and SSH key signing

## Structure

```
setup/
├── mac                     # Bootstrap script
├── macos                   # macOS preferences (Dock, Finder, cursor, text replacements)
├── Brewfile                # Homebrew packages and casks
└── text-replacements.plist # Looks of disapproval text replacements
config/
├── fish/         # Fish shell config + 32 custom functions
├── ghostty/      # Ghostty terminal config
├── nvim/         # Neovim LazyVim setup
├── omf/          # Oh My Fish packages
└── tmuxinator/   # Tmuxinator project sessions
direnvrc          # direnv layouts (anaconda, poetry)
editorconfig      # Editor defaults
envrc             # Environment variables
gitconfig         # Git with GPG signing
gitignore_global  # Global gitignore
gitmessage        # Commit message template
psqlrc            # PostgreSQL client config
tmux.conf         # tmux config (portable Intel/Apple Silicon)
tool-versions     # asdf runtime versions
```

## Fish Functions

| Category | Functions |
|---|---|
| Git | `gs`, `gc`, `co`, `gr`, `glog`, `pull`, `push`, `shove`, `pap`, `end_feature` |
| Elixir/Phoenix | `server`, `iexc`, `update_mix`, `hexu`, `rebaru`, `phoenixu` |
| PostgreSQL | `pg_init`, `pg_start`, `pg_stop`, `pg_user` |
| Docker | `stop_docker`, `rm_docker`, `rmi_docker` |
| Tmux | `mux`, `muxc`, `muxn`, `muxs` |
| System | `ll`, `myip`, `vim`, `tf`, `cleanpyc` |

## Updating Dotfiles

```bash
rcup        # Re-symlink after pulling changes
rcup -v     # Verbose output
mkrc <file> # Add a new dotfile to the repo
lsrc        # List all managed symlinks
rcdn        # Remove symlinks
```
