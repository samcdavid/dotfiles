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
- RCM links the runtime directories listed in `rcrc`: `claude/agents`, `claude/rules`, `agents/skills`, `agents/rules`, and `codex/agents`.
- The repo-local `AGENTS.md` symlink points to this file for Codex-style project guidance, but `AGENTS.md` is excluded from RCM and should not be linked into `$HOME`.

When changing skills or agents:

1. Edit canonical files under `claude/skills/`, `claude/agents/`, or `claude/rules/`.
2. If a new skill is added, add `agents/skills/<name> -> ../../claude/skills/<name>` so Codex can discover it.
3. If Claude agents changed, run `scripts/sync-codex-agents` to regenerate `codex/agents/*.toml`.
4. Keep longer skill instructions in one `references/protocol.md` per skill, and keep genuinely standalone material (gotchas, checklists, templates, mined patterns) as separate files in `references/`. Do not reintroduce the `protocol-index.md` + `protocol-sections/` split: the extra hop cost a serial read per section, its index rows carried no routing signal, and it let the same instruction drift between the index label and the section body. `check-agent-drift` caps reference files at 6000 words — split by topic when one outgrows that.
5. Run `scripts/check-agent-drift` before finishing larger instruction changes. It checks symlinks, generated Codex agents, critical-agent reasoning effort, home links, entrypoint budgets, cited-file existence, and dangling `$HOME` symlinks.
6. Run `rcup` after changing RCM-managed directories or `rcrc`, then verify the relevant `$HOME` symlinks. Renaming or deleting a file leaves a dangling `$HOME` symlink that `rcup` cannot clean up — remove it explicitly; `check-agent-drift` will flag it.
7. For a user-visible skill/agent behavior, safety, workflow, or model-routing change, add a concise entry with its commit SHA to `claude/skills/CHANGELOG.md`. This is the regression and known-good-point index; skip typo-only or formatting-only edits.

Git boundary for skills and agents:

- Local commits are **expected**, not gated: `my-implement` commits each verified delegated phase via the `commit` skill; `my-quick` and `address-pr-feedback` ensure every validated phase or fix is committed. Work that failed validation or escalated stays uncommitted.
- The gated boundary is remote: no push, no PR create/update, no published replies or thread resolution without an explicit request. `claude/rules/no-outward-actions.md` is the single source.
- `my-workflow` completes every planned phase through `my-implement` before it
  enters `implement-review`. Only then does the unattended five-pass
  review/repair loop begin: `my-review` -> bounded repair -> `my-validate` ->
  `my-review`. `implement-review` never performs initial plan execution, and
  nits never trigger another pass.
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
- Review-critical generated Codex agents (`adversarial-debate`, `security-reviewer`, `perf-reviewer`, `arch-reviewer`, `finding-verifier-high`) use `model_reasoning_effort = "xhigh"` in `codex/agents/*.toml`; `my-review` orchestration stays on the standard model.
- `scripts/sync-codex-agents` maps a source agent's `effort:` straight to `model_reasoning_effort`, falling back to `model: opus` -> `xhigh` for agents that have not moved to `effort:`.
- A per-agent `codex-model:` in agent frontmatter pins that one agent's Codex model and takes precedence over the repo-wide `CODEX_CRITICAL_MODEL` env var. It exists because a tiered agent pair needs two different Codex models, which a single env var cannot express — `finding-verifier-high` pins `gpt-5.6-sol` and `finding-verifier-low` pins `gpt-5.6-terra`. `check-agent-drift` fails if a `codex-model:` and its generated `model =` disagree, since a silent mismatch would collapse both tiers onto one model with no visible symptom.
- The `my-review` lens agents must point at each audit skill's `references/protocol.md`, not its `SKILL.md`. The entrypoint holds no checklist; the criteria live in the protocol file.
- `my-review` splits reporting from verifying. Lens agents report a **flat** findings list, each finding tagged with severity, risk, and confidence per `claude/skills/my-review/references/finding-axes.md`; they do not tier, filter, or verify their own findings, and they no longer return "What's Good". Step 6 then dispatches **one verifier per finding** — never batched — routed mechanically by those three levels: `finding-verifier-high` for Critical/High-risk/low-confidence claims, `finding-verifier-low` otherwise. The low tier has no PROMOTE verdict and returns `requires escalation` instead of guessing, which the orchestrator re-dispatches to the high tier. `adversarial-debate` is unchanged and still used for whole-review judgment (my-review's answer challenge and APPROVE/COMMENT challenge) plus ~15 other skills.

## Portability

`tmux.conf` resolves fish via `command -v` and installs/runs TPM from a fixed `~/.tmux/plugins/tpm` (git-clone install, done identically by both `setup/mac/install` and `setup/ubuntu/install`) — no OS or Homebrew-prefix branching needed. Its copy-mode yank binding falls back through `pbcopy` → `wl-copy` → `xclip` at runtime. Fish config uses generic asdf shim detection (`$HOME/.asdf/shims`) that works on both. `psqlrc` uses bare `nvim` from `PATH` rather than an absolute path. `gitconfig`'s `gh auth git-credential` helper uses a bare `gh` from `PATH` rather than a hardcoded Homebrew path; anything genuinely machine/OS-specific (`user.email`, GPG signing key, credential helper) is written to the untracked `~/.gitconfig.local`, included from `gitconfig`, by each OS's install script — never committed. There's no directory-based work/personal identity switching (no `gitconfig-work`/`gitconfig-personal`) — a single `user.email` in `~/.gitconfig.local` covers it; edit that file by hand for a machine that needs a different one.
