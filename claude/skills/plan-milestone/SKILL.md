---
model: opus
name: plan-milestone
description: Analyze Linear milestone issues, sequence dependencies, identify critical path, and optionally update issue relationships.
---

# Plan Milestone

Review a milestone for dependency reality and sequencing.

## Load Rules

Read `~/.claude/rules/question-policy.md` when available. Use `~/.agents/rules/` under Codex. For detailed Linear operations, read `references/protocol-index.md`.

## Flow

1. Load milestone, issues, sub-issues, relations, status, and comments.
2. Build an inventory of scope, dependencies, blockers, and code surfaces.
3. Identify critical path and parallelizable groups.
4. Find missing or incorrect Linear relationships.
5. Ask before mutating Linear relationships.

## Output

Return dependency map, recommended sequencing, parallel groups, relationship updates to make, and open questions.

