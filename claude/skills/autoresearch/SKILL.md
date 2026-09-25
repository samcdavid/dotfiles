---
name: autoresearch
description: "Autonomous iteration loop for a measurable goal: review, ideate, modify, verify, keep or rollback, repeat until interrupted or capped."
disable-model-invocation: false
---

# Autoresearch

Iterate toward a measurable goal without drifting.

## Load Rules

`~/.claude/rules/loop-detection.md`, `~/.claude/rules/no-outward-actions.md`, and `~/.claude/rules/context-checkpoint.md` are already loaded as memory under Claude Code — apply them without re-reading; read their `~/.agents/rules/` equivalents explicitly under Codex. For loop protocol and logging, read `references/protocol.md` plus specific reference files as needed.

## Flow

1. Define measurable objective, metric direction, limits, and verification command.
2. Establish baseline.
3. Iterate: propose one experiment, invoke `my-implement` with deferred commit, run verification, keep if better, discard if worse.
4. Log each iteration.
5. Stop on cap, repeated failure, no improvement, destructive risk, or user interruption.

## Output

Return best result, iterations run, changes kept/rolled back, verification data, and next promising direction.
