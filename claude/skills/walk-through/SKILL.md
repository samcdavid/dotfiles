---
model: sonnet
name: walk-through
description: Walk through a multi-item list one item at a time, capture decisions, and summarize resolutions.
---

# Walk Through

Process a list interactively without losing decisions.

## Load Rules

Read `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For detailed facilitation rules, read `references/protocol-index.md`.

## Flow

1. Parse the list and define what counts as resolved.
2. Present one item at a time.
3. Capture decision, rationale, owner, and follow-up.
4. Continue until complete or paused.
5. Summarize all resolutions.

## Output

Return completed items, unresolved items, decisions, and follow-ups.

