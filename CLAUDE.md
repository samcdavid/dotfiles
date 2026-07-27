# CLAUDE.md

This file provides guidance to Claude Code and Codex when working in this repository.

## Repository Overview

Personal dotfiles managed through the [rcm suite](https://github.com/thoughtbot/rcm). Supports both Intel (`/usr/local`) and Apple Silicon (`/opt/homebrew`) Macs.

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
- RCM links the runtime directories listed in `rcrc`: `claude/agents`, `claude/rules`, `agents/skills`, `agents/rules`, and `codex/agents`.
- The repo-local `AGENTS.md` symlink points to this file for Codex-style project guidance, but `AGENTS.md` is excluded from RCM and should not be linked into `$HOME`.

When changing skills or agents:

1. Edit canonical files under `claude/skills/`, `claude/agents/`, or `claude/rules/`.
2. If a new skill is added, add `agents/skills/<name> -> ../../claude/skills/<name>` so Codex can discover it.
3. If Claude agents changed, run `scripts/sync-codex-agents` to regenerate `codex/agents/*.toml`.
4. Keep longer skill instructions in one `references/protocol.md` per skill, and keep genuinely standalone material (gotchas, checklists, templates, mined patterns) as separate files in `references/`. Do not reintroduce the `protocol-index.md` + `protocol-sections/` split: the extra hop cost a serial read per section, its index rows carried no routing signal, and it let the same instruction drift between the index label and the section body. `check-agent-drift` caps reference files at 6000 words — split by topic when one outgrows that.
5. Run `scripts/check-agent-drift` before finishing larger instruction changes. It checks symlinks, generated Codex agents, critical-agent reasoning effort, home links, entrypoint budgets, cited-file existence, and dangling `$HOME` symlinks.
6. Run `rcup` after changing RCM-managed directories or `rcrc`, then verify the relevant `$HOME` symlinks. Renaming or deleting a file leaves a dangling `$HOME` symlink that `rcup` cannot clean up — remove it explicitly; `check-agent-drift` will flag it.

Git boundary for skills and agents:

- Local commits are **expected**, not gated: `implementation-executor` and `quick-implement-agent` commit their phase via the `commit` skill once their own validation passes, and `my-implement`, `my-quick`, and `address-pr-feedback` ensure every validated phase or fix is committed. Work that failed validation or escalated stays uncommitted.
- The gated boundary is remote: no push, no PR create/update, no published replies or thread resolution without an explicit request. `claude/rules/no-outward-actions.md` is the single source.
- `my-workflow`'s atomic block runs an unattended fix loop: `my-validate` -> `my-review` -> `address-pr-feedback local`, repeating until a review pass is clean of Critical and substantive non-blocking findings, capped at 3 iterations. Nits never trigger another iteration.
- The format/lint/test gate (`claude/hooks/checks.sh`) runs in exactly one place: `PreToolUse` with `if: Skill(commit)`. Because every code change lands through the `commit` skill, gating commits gates everything. The former `SubagentStop` and `Stop` copies were removed as duplicates, along with the `apf-mark.sh` marker they needed.

Frontmatter conventions:

- Skills use kebab-case tool fields (`allowed-tools`, `disallowed-tools`); agents use camelCase (`disallowedTools`). They are not interchangeable.
- Express reasoning intent with `effort:` rather than a model pin. See `claude/rules/model-escalation.md`.
- Read-only skills and agents set a tool deny list so read-only is mechanical, not just prose. `my-review` is deliberately excluded — it writes to `references/learned-misses.md`.
- Quote any `description:`/`when_to_use:` value containing a colon. The loader is lenient, but unquoted colons are invalid YAML and break `yq`-style tooling.
- `disable-model-invocation: true` also removes the description from the always-injected skill listing, so it is the lever for listing-budget savings. **Verified 2026-07-27:** it also blocks explicit `Skill` tool calls, not just autonomous ones — the call fails with `Skill <name> cannot be used with Skill tool due to disable-model-invocation`. Never set it on a skill another skill is told to invoke (the pipeline stages, `this-important`, `walk-through`, `commit`), and never write "run `X`" for a flagged skill — hand the user `/X` instead.
- New skills are not registered mid-session. Adding a skill requires a fresh session before it can be invoked, so a skill cannot be tested in the session that created it.
- Add `when_to_use:` only to skills that should fire unprompted; it is appended to the description in the always-on listing, so it costs context on every session.

Automation:

- `.githooks/pre-commit` runs `scripts/check-agent-drift`; this repo configures `core.hooksPath=.githooks`.
- Review-critical generated Codex agents (`adversarial-debate`, `security-reviewer`, `perf-reviewer`, `arch-reviewer`) use `model_reasoning_effort = "xhigh"` in `codex/agents/*.toml`; `my-review` orchestration stays on the standard model.
- `scripts/sync-codex-agents` maps a source agent's `effort:` straight to `model_reasoning_effort`, falling back to `model: opus` -> `xhigh` for agents that have not moved to `effort:`.
- The `my-review` lens agents must point at each audit skill's `references/protocol.md`, not its `SKILL.md`. The entrypoint holds no checklist; the criteria live in the protocol file.

## Portability

`tmux.conf` uses `if-shell` to detect architecture and set the correct Fish and TPM paths. Fish config uses generic asdf shim detection (`$HOME/.asdf/shims`) that works on both architectures. `psqlrc` uses bare `nvim` from `PATH` rather than an absolute path.
