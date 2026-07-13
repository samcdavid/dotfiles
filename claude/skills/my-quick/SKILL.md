---
model: sonnet
name: my-quick
description: One-pass implementation workflow for small, well-understood changes with lightweight research, focused TDD, validation, and self-review.
---

# My Quick

Handle small changes end-to-end without running the full workflow.

## Load Rules

Read `~/.claude/rules/tdd-phase.md`, `~/.claude/rules/loop-detection.md`, and `~/.claude/rules/no-outward-actions.md` when available. Use `~/.agents/rules/` under Codex. For tripwires or full checklist, read `references/protocol-index.md`, `references/tripwire-signals.md`, and `references/self-review-checklist.md`.

## Flow

1. Confirm the change is small and well-bounded.
2. Research only the directly relevant code and tests.
3. Write or update focused tests first when behavior changes.
4. Implement the minimal fix.
5. Run targeted checks and any cheap broader checks.
6. Self-review diff for correctness, scope creep, and missing tests.

## Trip Out

Stop and recommend full workflow if scope expands, requirements are unclear, many modules are touched, architecture changes emerge, or repeated failures occur.

## Output

Return changes made, checks run, residual risk, and whether a larger workflow is warranted.

