---
model: sonnet
effort: high
name: my-workflow
skill-only: coordinator
description: "Run research through analysis autonomously, stop once for decision confirmation, then—after coordination and explicit implementation approval—complete my-implement before entering implement-review's bounded repair loop."
disable-model-invocation: false
---

# My Workflow

Run the delivery pipeline as resumable stages. This is the explicit skill-only
coordinator: it has no runner. Stages 1-9 run back-to-back: research facts and
log decisions provisionally. Stop after stage 9 at the **Decisions Checkpoint**.
On confirmation, run stage 10; absent overlap and with explicit implementation
approval, complete `my-implement` once, record it, then enter `implement-review`'s
bounded review/repair loop. Details: `references/protocol.md`.

Default to `my-research` on a new workflow. Never infer implementation permission. It requires stages 1-9 complete, a completed behavior-first `my-test-strategy`, eval `completed`/`not_applicable`, confirmed Decisions Checkpoint decisions, and a fresh post-checkpoint coordination `passed` gate; migrations also require their safety gate.

For `my-quick`, ledger route, reason, expected scope, and handoff command before invoking it.

Migration work uses the full pipeline, never `my-quick`. Read `references/migration-safety.md` at intake and before implementation; its audit and matrix are a hard gate.

## Load Rules

Read first:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/model-escalation.md`

Use `~/.agents/rules/` when running through Codex.

Load targeted references as needed:

- `references/stage-routing.md` when starting or resuming.
- `references/checkpoint-policy.md` before the Decisions Checkpoint and stage
  12's final review checkpoint.
- `references/cross-workflow-coordination.md` at intake, stage 10
  (post-checkpoint), and stage 12's final review checkpoint, when the task is a
  Linear issue.
- `references/autonomy-boundaries.md` when a stage wants to ask questions.
- `references/final-report.md` before final handoff.
- `references/migration-safety.md` at intake and before implementation when migrations are in scope.

## Pipeline

1. `my-research` 2. `my-spec` 3. `my-clarify` 4. `my-architecture-plan` 5. `my-test-strategy` 6. `my-plan` 7. `my-observe` 8. `my-eval-plan` (or ledger `not_applicable`) 9. `my-analyze`.

Stages 1-9 run back-to-back, no stop; every decision gets a recommendation, logs as provisional, run continues. **Decisions Checkpoint** after stage 9: present every artifact and provisional decision for confirm/override — the point to clear context; resume re-enters via the ledger.

10. Pre-implementation coordination check (Linear issues only), run only after
    that checkpoint: fresh sibling scan against the finalized plan. Stop only on
    overlap; otherwise continue to authorized implementation.
11. Gated implementation stage: `my-implement` completes every planned phase and
    holistic test gate. No review/repair loop starts during this stage.
12. Post-implementation loop: `implement-review` starts only after stage 11 is
    complete, then owns `my-review` -> repair -> `my-validate` -> `my-review`,
    capped at 5 review passes. Checkpoint after its terminal result.

## Flow

1. Detect the current git branch and find a ledger whose `branch` matches; fall back to Linear ID/slug/topic on the default branch or no match.
2. Establish task once (a branch-matched ledger's task wins, no confirmation needed).
3. Read or create `~/.claude/thoughts/shared/workflows/<slug>.md`, recording the branch.
4. Loose artifacts are evidence for a stage, never permission to skip it.
5. Decide full pipeline vs. `my-quick`; ledger the decision before handoff.
6. Run every incomplete stage from `references/stage-routing.md`, dispatching its runner in embedded mode when it exists and falling back to the stage skill entrypoint during rollout. Run stages 1-9 back-to-back. Run stage 10, then `my-implement`, then `implement-review` only after the checkpoint is confirmed and implementation is explicitly authorized.
7. Update the ledger silently after each stage: status, artifacts, assumptions, provisional decisions.
8. Stop once, after stage 9, with the consolidated Decisions Checkpoint.
9. On resume: confirmed decisions run stage 10, then (if clear and authorized)
   complete `my-implement` before `implement-review`; an override re-runs only
   invalidated stages; a stage-10 overlap stops separately for that one decision.

For migration work, the ledger records `migration_safety: required`, audit path, matrix, and validation. A missing, failed, or blocked gate blocks action absent an explicit, recorded override.

Factual questions are researched; decisions get a recommendation, logged provisional, confirmed at the checkpoint rather than asked live. Validated phases/fixes commit locally; no pushes, PRs, or remote changes unless requested.

## Output

At the Decisions Checkpoint, a stage-10 overlap stop (if any), and stage 12's
end: completed stages, artifact paths, every provisional decision (options,
recommendation, evidence) for confirm/override, assumptions, next stage, resume
command, and whether context can be cleared safely.
