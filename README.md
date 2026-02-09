# Dotfiles

Personal dotfiles managed with the [rcm suite](https://github.com/thoughtbot/rcm). Works on both Intel and Apple Silicon Macs.

## Setup

```bash
git clone git@github.com:samcdavid/dotfiles.git ~/.dotfiles
rcup
```

## Environment

- **Shell**: Fish with Oh My Fish and 30+ custom functions
- **Editor**: Neovim with LazyVim framework
- **Terminal**: Ghostty + tmux with vim-like bindings and TPM
- **Version Manager**: asdf (Ruby, Node.js, Erlang, Elixir, Python, Go)
- **VCS**: Git with GPG signing

## Structure

```
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

## Post-Setup

After running `rcup`:

1. Install asdf runtimes: `asdf install`
2. Install TPM plugins: `<prefix> + I` inside tmux
3. Install OMF packages: `omf install` inside fish
