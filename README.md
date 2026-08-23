# Dotfiles

Personal dotfiles and machine setup, managed with the [rcm suite](https://github.com/thoughtbot/rcm). Works on Intel and Apple Silicon Macs, and on Ubuntu (GNOME).

## New Machine Setup

**macOS:**
```bash
git clone https://github.com/samcdavid/dotfiles.git ~/.dotfiles && ~/.dotfiles/setup/mac/install
```

**Ubuntu:**
```bash
git clone https://github.com/samcdavid/dotfiles.git ~/.dotfiles && ~/.dotfiles/setup/ubuntu/install
```

Both do the same shape of thing for their OS — install packages, symlink
dotfiles, authenticate with GitHub, generate SSH/GPG keys, set fish as the
default shell, install asdf runtimes, Oh My Fish, Neovim/tmux plugins, and
configure OS preferences — logged to `~/laptop.log` (auto-numbered on
re-runs: `laptop1.log`, `laptop2.log`, etc.). See `setup/mac/README.md` and
`setup/ubuntu/README.md` for the exact step list and OS-specific notes.

### Manual Steps

- Set up 1Password before running either script
- Ubuntu: see `setup/ubuntu/README.md` for a few steps that aren't fully
  unattended (Secure Boot, NVIDIA driver reboot, NordVPN login)

## Environment

- **Shell**: Fish with Oh My Fish and 30+ custom functions
- **Editor**: Neovim with LazyVim framework
- **Terminal**: Ghostty + tmux with vim-like bindings and TPM
- **Version Manager**: asdf (Ruby, Node.js, Erlang, Elixir, Python, Go)
- **VCS**: Git with GPG and SSH key signing

## Structure

```
setup/
├── mac/          # macOS bootstrap — see setup/mac/README.md
└── ubuntu/       # Ubuntu bootstrap — see setup/ubuntu/README.md
config/
├── fish/         # Fish shell config + 32 custom functions
├── ghostty/      # Ghostty terminal config
├── nvim/         # Neovim LazyVim setup
├── omf/          # Oh My Fish packages
└── tmuxinator/   # Tmuxinator project sessions
direnvrc          # direnv layouts (uv)
editorconfig      # Editor defaults
envrc             # Environment variables
gitconfig         # Git with GPG signing (signing key/credential helper come from the untracked ~/.gitconfig.local)
gitignore_global  # Global gitignore
gitmessage        # Commit message template
psqlrc            # PostgreSQL client config
tmux.conf         # tmux config (portable across Mac/Ubuntu, Intel/Apple Silicon)
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
| System | `ll`, `myip`, `vim`, `tf`, `cleanpyc`, `update_nvim` |

## Updating Dotfiles

```bash
rcup        # Re-symlink after pulling changes
rcup -v     # Verbose output
mkrc <file> # Add a new dotfile to the repo
lsrc        # List all managed symlinks
rcdn        # Remove symlinks
```
