---
model: sonnet
name: quick-implement
description: Execute a quick-plan one phase at a time using quick-implement-agent for TDD or direct-edit phases.
---

# Quick Implement

Run an approved quick-plan with compact phase dispatch.

## Load Rules

Read `~/.claude/rules/subagent-contract.md`, `~/.claude/rules/tdd-phase.md`, and `~/.claude/rules/loop-detection.md` when available. Use `~/.agents/rules/` under Codex. For full behavior, read `references/protocol-index.md`.

## Flow

1. Resolve the quick plan path from `$ARGUMENTS` or recent quick plans.
2. Read completed checkboxes and resume first incomplete phase.
3. Dispatch one `quick-implement-agent` phase at a time.
4. Re-run phase success criteria yourself.
5. Mark completed phase checkboxes in the plan.
6. Stop on missing required phase inputs, broad scope, major deviation, or repeated failure.

## Output

Return phases completed, checks run, deviations, and remaining phases or blockers.

