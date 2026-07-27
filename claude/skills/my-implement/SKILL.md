---
model: sonnet
name: my-implement
description: Execute an approved plan phase by phase. Dispatches one implementation-executor at a time, enforces RED -> GREEN -> VALIDATE, re-verifies results, and stops on repeated failure.
---

# Implement Plan

Orchestrate an approved implementation plan. The executor writes code; this skill slices phases, dispatches one executor at a time, re-verifies, updates the plan, and owns loop detection.

## Load Rules

Read these first:

- `~/.claude/rules/tdd-phase.md`
- `~/.claude/rules/subagent-contract.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/context-checkpoint.md`

If running through Codex, use the same files under `~/.agents/rules/`.

For unusual or ambiguous implementation runs, read `references/protocol.md`.

## Flow

1. Resolve the plan path from `$ARGUMENTS`; otherwise list plans in `~/.claude/thoughts/shared/plans/` and ask which one.
2. Read the plan fully. Resume from the first unchecked phase.
3. Create one todo per phase.
4. For each phase, build a compact slice for `implementation-executor`:
   - phase overview
   - RED tests
   - GREEN changes
   - allowed paths
   - success criteria
   - verification commands
   - architectural constraints
   - relevant gotchas
5. Dispatch exactly one executor.
6. Re-run the phase success criteria yourself and read the diff. Read the phase's committed diff (`git show`) when the executor committed; otherwise read the working tree.
7. If the phase conforms, confirm the executor committed it. If it did not — and validation passed — commit it yourself via the `commit` skill scoped to the phase's paths, so every green phase lands as its own commit. Then mark its checklist items complete in the plan and continue.
8. If it fails, apply the loop-detection rule. Retry only with new information. Leave failed work uncommitted.
9. After all phases, run the plan’s full validation strategy and mark the plan implemented. Report the commit series.

## Stop Conditions

Stop instead of dispatching when:

- A phase has no RED tests or no success criteria.
- The phase is too broad to fit a compact slice.
- Required files or APIs differ from the plan in a major way.
- The same failure reaches the loop-detection limit.
- A fix requires an outward action or product/scope decision.

## Output

Summarize phases completed, deviations, tests run, failed checks if any, files changed, the commit SHA and subject for each phase, anything left uncommitted and why, and whether `/my-validate` should run next.

