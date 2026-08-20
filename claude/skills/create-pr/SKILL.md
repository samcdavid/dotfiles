---
model: sonnet
name: create-pr
description: Create or update a GitHub PR with concise description, review guidance, triggered specialty reviews, and focus areas.
---

# Create PR

Prepare a useful pull request from the current branch.

## Load Rules

Read `~/.claude/rules/no-outward-actions.md` when available. Use `~/.agents/rules/` under Codex. For PR template details, read `references/pr-template.md`, `references/review-categories.md`, and `references/protocol.md` as needed.

## Flow

1. Inspect branch, commits, diff, linked tickets, existing PR state, and implementation decision records.
2. Determine intent, user-facing changes, implementation decisions, tests, risks, and review focus.
3. If a PR exists, update its body; otherwise create one only when requested or clearly intended.
4. Include specialty review guidance when code touches security, architecture, performance, QA, requirements, migrations, dependencies, or ops.
5. Do not push unless explicitly asked.

## Output

Return PR URL, title, body summary, implementation decisions, review focus areas, and any missing information.
