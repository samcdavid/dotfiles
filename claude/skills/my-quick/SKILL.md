---
model: sonnet
name: my-quick
description: One-pass implementation workflow for small, well-understood changes with lightweight research, focused TDD, validation, and self-review.
---

# My Quick

Handle small changes end-to-end without running the full workflow.

## Load Rules

Read `~/.claude/rules/tdd-phase.md`, `~/.claude/rules/loop-detection.md`,
`~/.claude/rules/no-outward-actions.md`, and
`~/.claude/rules/human-readable-communication.md` when available. Use
`~/.agents/rules/` under Codex. For tripwires or full checklist, read
`references/protocol.md`, `references/tripwire-signals.md`, and
`references/self-review-checklist.md`.
Read `~/.claude/rules/verification-ladder.md` (or `~/.agents/rules/`) before
running checks.

## Flow

1. Confirm the change is small and well-bounded. A caller may supply a
   `preconfirmed_feedback_microfix` contract only after evidence-backed review
   triage has accepted its exact behavior, allowed paths, and focused proving
   check; in that case, reuse that confirmation rather than asking the user to
   approve the same scope again.
2. Research only the directly relevant code and tests.
3. Build one bounded `my-implement` slice, including focused RED tests for behavior changes, allowed paths, and verification commands.
4. Invoke `my-implement` to perform the bounded edit.
5. Reuse current implementation evidence; run only targeted or broader checks it does not cover.
6. Self-review diff for correctness, scope creep, and missing tests.

## Trip Out

Stop and recommend full workflow if scope expands, requirements are unclear, many modules are touched, architecture changes emerge, or repeated failures occur.
For a preconfirmed feedback micro-fix, return control to the feedback runner
instead of asking the user whether to continue; it chooses the normal repair
path and preserves the reviewer triage record.

## Output

Return the actual changes made, checks run, residual risk, and whether a larger
workflow is warranted. Pair any phase, finding, or commit identifier with its
plain-language meaning.
