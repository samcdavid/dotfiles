# setup/incrementals

Standalone, idempotent scripts for catching up **one piece** of setup on a
machine that already ran the full `mac/install` or `ubuntu/install` — no
need to re-run (or diff against) the whole bootstrap just to pick up
something added since.

These are deliberately **not** called from `mac/install` or `ubuntu/install`,
and not called by each other. Each script here is self-contained, safe to
run more than once, and works unmodified on both mac and Ubuntu (branching
internally on `brew` vs `apt` where the two differ) — so the full installs
keep their own copy of the same steps, and this is the separate path for
"just get me current on X" on a machine you don't want to re-bootstrap.

```bash
~/.dotfiles/setup/incrementals/tree-sitter.sh
~/.dotfiles/setup/incrementals/local-bin-path.sh   # or: ... zsh fish
```

## Files

```
tree-sitter.sh        # tree-sitter-cli + language grammars
local-bin-path.sh     # ~/.local/bin at the front of PATH for bash, zsh, fish
```

`local-bin-path.sh` needs nothing else from this repo, so it can be shared on
its own. It appends a marked block to each bash and zsh startup file (and sets
fish's universal `fish_user_paths`); delete a block to undo it. Tests live in
`tests/test_local_bin_path.py`.
