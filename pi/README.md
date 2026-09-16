# pi

Global config for [pi](https://pi.dev), the coding-agent CLI used for work
that must route through open-weight models (see
`~/Developer/dscout-wt/main/.pi/README.md` for the project-local ganglia
gateway wiring — that part is dscout-specific and stays out of this repo).

Everything here is auto-discovered by pi from `~/.pi/agent/` — no `-e`/`--skill`
flags needed.

- `agent/AGENTS.md` — symlink to `claude/AGENTS.md`, the same Global
  Principles content Claude Code loads from `~/.claude/CLAUDE.md`. Pi reads
  `~/.pi/agent/AGENTS.md` as its global context file, same as Claude Code's
  `~/.claude/CLAUDE.md` and Codex's root `AGENTS.md`.

  `rcrc`'s `EXCLUDES` has a bare `AGENTS.md` entry (to keep this repo's own
  root `AGENTS.md` off `$HOME`), and rcm matches excludes against a file's
  basename as well as its full path with no way to scope by directory depth
  — so it blocks *any* `AGENTS.md`, including this one, from the normal
  per-file symlink pass. `hooks/post-up/pi-agents-md` links it explicitly;
  every `rcup` run re-triggers that hook, so this stays current without a
  manual step.
- `agent/extensions/dotfiles-rules.ts` — Claude Code auto-loads every file
  under `~/.claude/rules/` as always-on instructions, not just CLAUDE.md; pi
  has no equivalent for a rules directory, so this extension inlines every
  `*.md` under `~/.agents/rules/` (already symlinked from `claude/rules/`)
  into the system prompt at session start.
- `agent/extensions/bell.ts` — rings the terminal bell on the current tmux
  pane via `agent_settled`, the same tmux-targeted `printf '\a'` command
  Claude Code's Stop/Notification hooks and Codex's `hooks.Stop`/
  `hooks.PermissionRequest` already run, so `tmux.conf`'s `monitor-bell`
  window highlight fires for pi too.

Skills are already covered without any pi-specific file: pi discovers global
skills from `~/.agents/skills/`, which `rcrc` already symlinks to
`agents/skills/` in this repo.

Pi has no built-in subagent/Task-tool concept (see `docs/usage.md` in pi's
own package: "intentionally does not include ... sub-agents"), so
`claude/agents/*.md` runner definitions that skills dispatch to via the Agent
tool do not carry over — a skill written as a thin wrapper around a runner
agent (e.g. `start-day` → `skill-start-day`) will not resolve that dispatch
under pi. Skills with no runner indirection work as-is.
