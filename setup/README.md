# setup/

OS-specific machine bootstrap. Each subfolder is self-contained and owns its
own package list, third-party repo/key setup, and system preferences —
nothing in here is shared between OSes except the invocation shape.

```
setup/
├── mac/      # macOS bootstrap — see mac/README.md
└── ubuntu/   # Ubuntu bootstrap — see ubuntu/README.md
```

Both are invoked the same way from a fresh clone:

```bash
~/.dotfiles/setup/mac/install      # macOS
~/.dotfiles/setup/ubuntu/install   # Ubuntu
```

## Keeping the two in sync

They aren't generated from a shared template — each `install` is a plain,
readable script for its own OS. When a step is added or changed on one side
(a new asdf plugin, a new manual step, a new tool), check whether the other
side needs the equivalent change. The two currently stay in step on:

- Log file naming and auto-numbering (`~/laptop.log`, `laptop1.log`, ...)
- The overall step order: package install → dotfiles symlinks (`rcup`) →
  GitHub auth → SSH key → default shell → asdf → Oh My Fish → Neovim
  plugins → tmux/TPM → GPG signing → OS preferences
- TPM is installed via `git clone` into `~/.tmux/plugins/tpm` on both —
  not a package-manager formula — so `tmux.conf` needs no OS branching
- The `~/.gitconfig.local` pattern for anything machine-specific
  (GPG signing key, credential helper) that must never be committed

Neither script sources a local-overrides file (no `~/.laptop.local`
equivalent) — the goal is that a machine's setup is fully described by what's
committed here, not by undocumented per-machine state.

This entire `setup/` directory is excluded from `rcup` via `rcrc`'s
`EXCLUDES`, so nothing under here ever gets symlinked into `$HOME`.
