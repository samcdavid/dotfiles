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
  per-file symlink pass. `hooks/post-up/agents-md` links it explicitly;
  every `rcup` run re-triggers that hook, so this stays current without a
  manual step. The same hook also links OpenCode's
  `~/.config/opencode/AGENTS.md`.
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

Subagents: pi core has none, but pi ships a subagent extension as an example
in its npm package (`examples/extensions/subagent`). `hooks/post-up/pi-subagent-extension`
links that directory from the installed pi package to
`~/.pi/agent/extensions/subagent` on every `rcup`, re-resolving the path in case
the node version moved. It registers a `subagent` tool that runs each agent as a
separate `pi` process and discovers agents from `~/.pi/agent/agents/*.md`.

- `agent/agents/*.md` — generated from `claude/agents/*.md` by
  `scripts/sync-pi-agents`; do not edit by hand. A Claude `disallowedTools`
  denylist becomes a pi `tools:` allowlist (read-only agents get
  `read, bash, grep, find, ls`). Claude model names are dropped so every
  subagent inherits the session model; add `pi-model:` to a source agent to pin
  one. `rcrc` links the directory to `~/.pi/agent/agents`.

Skills that dispatch "via the Agent tool" now resolve through the `subagent`
tool under pi, but the dispatch wording is Claude-specific, so the model has to
map it. Differences to expect: the deep-tier `model: opus` pins on
`adversarial-debate`/`finding-verifier-high` do not carry over, so they run on
the session model unless given a `pi-model:`. `--tools` also filters extension
tools, so agents with a `tools:` allowlist cannot dispatch nested subagents —
matching the Claude-side `Agent` deny — while unrestricted runners (the
`skill-*` agents) still can.
