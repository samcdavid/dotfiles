---
model: sonnet
name: gotcha
description: Capture a discovered failure pattern or correction as a gotcha for an existing skill.
---

# Gotcha

Record a reusable failure pattern where future agents will see it.

## Load Rules

Read `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For exact formatting, read `references/protocol-index.md`.

## Flow

1. Identify the skill affected by the mistake or correction.
2. Distill the pattern, trigger, wrong behavior, correct behavior, and why it matters.
3. Append to that skill's `gotchas.md` or create it if appropriate.
4. Keep it short and operational.

## Output

Return the file updated and the gotcha added.

