---
model: sonnet
effort: low
name: pr-overview
description: "Give a brief, categorized overview of a PR or local diff, flagging requirement/behavior-relevant changes: requirement changes, edited existing test cases, migrations, signature changes, public interface changes, branching-condition changes, feature-flag use, comment quality, and monkey patching. For a PR, also summarizes existing review comments and where reviewers lean."
when_to_use: "Use when the user wants a quick orientation on a PR (number/URL) or the current local diff before reading it in full, rather than a full review or verdict."
disallowed-tools: Edit, Write, NotebookEdit
---

# PR Overview

A brief, structured "what changed and what to look at" summary — not a review. No verdict, no approval/blocking language, no findings severity.

## Load Rules

Already loaded as memory under Claude Code — apply without re-reading:

- `~/.claude/rules/pr-mode-readonly.md`
- `~/.claude/rules/pr-cost-control.md`

Under Codex, read the `~/.agents/rules/` equivalents explicitly.

## Scope

Resolve the target from `$ARGUMENTS` or conversation context:

- **PR** (number, `owner/repo#N`, or URL): fetch via `gh api`/`gh pr diff` per `pr-cost-control.md`'s scoped-fetch shape. Treat the PR diff and head SHA as source of truth per `pr-mode-readonly.md` — do not check the PR out to a local branch, and do not read changed files from the working tree as if they were PR contents.
- **Local diff/branch** (no PR given, or explicitly asked for "local"/"my changes"): use `git diff` against the merge-base with the default branch (or whatever base the user names). Uncommitted and committed-but-unpushed changes both count.

If neither exists (clean tree, nothing ahead of base), say so and stop — do not invent a target.

## Categories

Read `references/protocol.md` for how to detect each category (file patterns, grep heuristics, languages/frameworks to watch for). Scan the full diff once and bucket hunks into:

1. **Product requirement changes** — copy, validation rules, business logic thresholds, permission/role checks that change observable behavior.
2. **Edited existing test cases** — pre-existing test cases changed or deleted (added tests don't count); flag assertion changes vs. pure refactor.
3. **New database migrations** — new migration files, schema-change DDL, or ORM model field changes implying one.
4. **Function/method signature changes** — added/removed/reordered/retyped parameters, changed return type, changed arity, changed default values.
5. **Public interface changes** — exported classes/modules, API route definitions/contracts, public method additions/removals/renames.
6. **Branching-condition changes** — modified `if`/`case`/`switch`/guard conditions, especially ones gating a different code path than before.
7. **Feature flag use** — flags added, checked, or removed (`if flag_enabled`, LaunchDarkly/Flipper/env-var gate style checks, flag config files).
8. **Comment quality** — new/changed comments referencing a Linear ID outside `TODO`, an agent-generated ID, dead code, or narrating *what*/*how* instead of *why*.
9. **Monkey patching** — code (mostly tests) that replaces a real module/class/function at runtime instead of injecting the dependency.

Omit a category with nothing to report — do not list it as "none found."

## Review Activity (PR mode only)

For a PR, fetch existing reviews/comments via `pr-cost-control.md`'s scoped GraphQL query and follow `references/protocol.md`'s "Review Activity Summary" section to report, in plain language: each reviewer's latest stance (`APPROVED`/`CHANGES_REQUESTED`/`COMMENTED`), how many unresolved threads remain, and a one-line factual lean ("two approvals, no unresolved threads — trending toward merge"), not this skill's own opinion. State plainly when there's no review activity yet.

A stance comes from the formal review event **or** from a comment's own text — read every comment body, not just its GitHub event type. At least one automated review bot on this org posts its verdict as plain comment text (e.g. the words "APPROVE" or "REQUEST_CHANGES" inside a regular issue/PR comment) rather than submitting a real GitHub review event, so `gh api .../reviews` alone misses it. `references/protocol.md` has the parsing rule.

## Output

Lead with one or two sentences: what the PR/diff does at a high level. Then a compact list per non-empty category, each entry as `file:line` plus a one-line plain-language description of the change (not a copy of the diff hunk). In PR mode, follow with the Review Activity summary. Close with a one-line file-count/size gauge (files changed, lines +/-) so the user can judge how long a full read will take. No verdict, no recommendation to approve/request changes — that's `my-review`'s job, and this skill should point there if the user asks for one.
