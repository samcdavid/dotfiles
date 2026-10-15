# CLAUDE.md

This file provides guidance to Claude Code and Codex when working in this repository.

## Repository Overview

Personal dotfiles managed through the [rcm suite](https://github.com/thoughtbot/rcm). Supports Intel (`/usr/local`) and Apple Silicon (`/opt/homebrew`) Macs, and Ubuntu (GNOME). OS-specific bootstrap lives under `setup/mac/` and `setup/ubuntu/` — see `setup/README.md` for how the two are kept in sync; everything else in the repo (`config/`, root dotfiles) is shared and OS-agnostic.

- `rcup` creates symlinks from this repo into `$HOME`.
- `rcdn` removes symlinks.
- `mkrc` adds a new dotfile to the repo.
- `lsrc` lists managed symlinks.
- Files under `config/` are symlinked into `~/.config/`.

## Claude and Codex Skills/Agents

- Canonical skill definitions live in `claude/skills/`.
- Canonical Claude agent definitions live in `claude/agents/`.
- Codex-visible personal skills are exposed through `agents/skills/`; each entry symlinks back to `claude/skills/<name>`.
- Shared reusable rules live in `claude/rules/`; `agents/rules` symlinks back to that directory.
- Codex custom agents are generated TOML files under `codex/agents/` from `claude/agents/*.md`.
- OpenCode subagents are generated markdown files under `config/opencode/agents/` from `claude/agents/*.md`, via `scripts/sync-opencode-agents`. Skills need no equivalent generation step: OpenCode discovers `~/.agents/skills/<name>/SKILL.md` natively (its "Agent-compatible" skill path), which RCM already populates from `agents/skills/`.
- OpenCode global instructions: `config/opencode/AGENTS.md` symlinks to `claude/AGENTS.md`. Rules reach OpenCode only through the `instructions` field of the untracked, machine-local `~/.config/opencode/opencode.json`; `hooks/post-up/opencode-rules` merges `"~/.agents/rules/*.md"` into it on every `rcup`.
- OpenCode plugins live in `config/opencode/plugins/`, which `rcrc` links as a whole directory: OpenCode silently skips a directory plugin whose entry files are symlinks, which rcm's per-file linking would produce. OpenCode 2.x uses a different plugin API from its published docs and `@opencode-ai/plugin` typings: a default export `{ id, setup(ctx) }`, events on `event.data`, and no `session.idle`. A plugin in the old 1.x shape fails to load with only a WARN in `~/.local/share/opencode/log/opencode.log`. Every TUI attaches to one shared background server (`opencode serve --service`), so anything per-terminal (like `$TMUX_PANE`) must live in a directory plugin's `tui.ts` (which also needs a `server.ts`), not a server plugin. The shared server keeps the first copy of a plugin it loads; run `opencode service restart` after changing one, and test with `--standalone`.
- Pi subagents are generated markdown files under `pi/agent/agents/` from `claude/agents/*.md`, via `scripts/sync-pi-agents`, and are dispatched by pi's bundled subagent extension, which `hooks/post-up/pi-subagent-extension` links from the installed pi package into `~/.pi/agent/extensions/subagent`. See `pi/README.md`.
- Both `AGENTS.md` context files (pi's and OpenCode's) are linked by `hooks/post-up/agents-md`, because the `AGENTS.md` exclude in `rcrc` blocks them from rcm's normal pass.
- All generators import shared frontmatter parsing from `scripts/lib/agent_frontmatter.py`; a future target (e.g. another agent CLI) should add another `scripts/sync-<target>-agents` script against that same module rather than a second source of truth.
- RCM links the runtime directories listed in `rcrc`: `claude/agents`, `claude/rules`, `agents/skills`, `agents/rules`, `codex/agents`, `config/opencode/agents` and `config/opencode/plugins` (which RCM's `config/` convention places under `~/.config/opencode/`), and `pi/agent/agents`.
- This file (`AGENTS.md`) is the canonical content; the repo-local `CLAUDE.md` is a symlink to it, so Claude Code and Codex read the same project guidance from a single source. `AGENTS.md` is excluded from RCM and should not be linked into `$HOME` — Codex discovers it directly from the project root.

Skill style (reset 2026-10-14, undo point: tag `pre-reset`):

- Skills are short prompts in the spirit of `eli8g`: a `SKILL.md` of roughly 300 words or fewer, with a `references/` file only for genuinely standalone material (a template, a checklist). No runner/wrapper agents, ledgers, envelopes, or pipelines. The old multi-stage workflow was replaced by one `work` skill; `my-review` is the 2026-06-02 reviewer restored (its lens checklists live in `my-review/references/lenses/`).
- Every skill and agent sets `effort: xhigh` and no `model:`, so everything runs on the session model.
- Agents exist only where a skill dispatches them: `review-orchestrator` and its research helpers for `my-review`, and `adversarial-debate` for `my-review`, `prove-it`, and `address-pr-feedback`.
- Always-loaded rules stay minimal (`no-outward-actions.md`, `comment-style.md`); they cost context in every session and subagent.
- Skills keep no learned-misses or gotchas queue of their own (`my-review`'s `capture`/`promote` queue was retired 2026-10-15). Lasting lessons about a codebase go in that repo's `docs/`; `work` and `my-review` route them there. `my-review/gotchas.md` is a fixed list of the reviewer's own failure modes, edited by hand.

When changing skills or agents:

1. Edit canonical files under `claude/skills/`, `claude/agents/`, or `claude/rules/`.
2. If a new skill is added, add `agents/skills/<name> -> ../../claude/skills/<name>` so Codex can discover it.
3. If Claude agents changed, run `scripts/sync-codex-agents`, `scripts/sync-opencode-agents`, and `scripts/sync-pi-agents` to regenerate `codex/agents/*.toml`, `config/opencode/agents/*.md`, and `pi/agent/agents/*.md`.
4. Run `scripts/check-agent-drift` before finishing. It checks symlinks, generated agents, home links, entrypoint budgets, cited-file existence, and dangling `$HOME` symlinks. The cited-file check resolves backticked `*.md` paths only against the citing file's directory, its skill/agent root, `claude/skills/`, `claude/agents/`, and the `~/.claude/`/`~/.agents/` prefixes — never the repo root — so cite repo-root files as a bare filename or a `~/` home path.
5. Run `rcup` after changing RCM-managed directories or `rcrc`. Renaming or deleting a file leaves a dangling `$HOME` symlink that `rcup` cannot clean up — remove it explicitly; `check-agent-drift` will flag it.
6. For a user-visible behavior change, add a concise entry with its commit SHA to `claude/skills/CHANGELOG.md`.

Boundaries:

- Local commits are expected; remote actions (push, PR create/update, published reviews/replies, thread resolution) need an explicit request. `claude/rules/no-outward-actions.md` is the single source.
- Lint and format enforcement belongs to each project's own pre-commit hooks, not Claude-side tooling.

Frontmatter conventions:

- Skills use kebab-case tool fields (`allowed-tools`, `disallowed-tools`); agents use camelCase (`disallowedTools`). They are not interchangeable.
- Quote any `description:`/`when_to_use:` value containing a colon.
- `disable-model-invocation: true` also blocks explicit `Skill` tool calls (verified 2026-07-27). Never set it on a skill another skill invokes (e.g. `commit`).
- New skills are not registered mid-session; test a new skill in a fresh session.
- Add `when_to_use:` only to skills that should fire unprompted; it costs context in every session.

Automation:

- `.githooks/pre-commit` runs `scripts/check-agent-drift`; this repo configures `core.hooksPath=.githooks`.
- `scripts/sync-codex-agents` maps a source agent's `effort:` straight to `model_reasoning_effort`.

## Portability

`tmux.conf` resolves fish via `command -v` and installs/runs TPM from a fixed `~/.tmux/plugins/tpm` (git-clone install, done identically by both `setup/mac/install` and `setup/ubuntu/install`) — no OS or Homebrew-prefix branching needed. Its copy-mode yank binding falls back through `pbcopy` → `wl-copy` → `xclip` at runtime. Fish config uses generic asdf shim detection (`$HOME/.asdf/shims`) that works on both. `psqlrc` uses bare `nvim` from `PATH` rather than an absolute path. `gitconfig`'s `gh auth git-credential` helper uses a bare `gh` from `PATH` rather than a hardcoded Homebrew path; anything genuinely machine/OS-specific (`user.email`, GPG signing key, credential helper) is written to the untracked `~/.gitconfig.local`, included from `gitconfig`, by each OS's install script — never committed. There's no directory-based work/personal identity switching (no `gitconfig-work`/`gitconfig-personal`) — a single `user.email` in `~/.gitconfig.local` covers it; edit that file by hand for a machine that needs a different one.
