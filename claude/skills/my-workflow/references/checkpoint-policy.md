# Checkpoint Policy

Load before ending any `my-workflow` stage.

There are three possible stops in the whole pipeline; only two are guaranteed. Everything else runs straight through:

- Stages 1-8 (`my-research`, `my-spec`, `my-clarify`, `my-architecture-plan`, `my-plan`, `my-observe`, `my-eval-plan` when applicable, `my-analyze`) -> continue automatically. Update the ledger silently: status, artifact path, factual assumptions, and any provisional decision (options, recommendation chosen, evidence). Do not stop.
- **Decisions Checkpoint**, after stage 8 -> always stop, guaranteed. Present every artifact from stages 1-8 and every provisional decision logged along the way together, so the user can confirm or override. This is the deliberate point to clear context — resuming reads the ledger and continues from here. Nothing runs stage 9 or touches `my-implement` before this stop happens and the user resumes past it.
- Stage 9, Pre-implementation coordination check -> runs only after the Decisions Checkpoint is confirmed. Stop only if it finds a sibling overlap (its own small checkpoint, just that one decision); if clear, continue straight into the atomic block with no further stop.
- Atomic block (`my-implement` -> fix loop) -> stop after the final review output.

The fix loop is **not** checkpointed per iteration. `my-validate` -> `my-review` -> `address-pr-feedback local` repeats without stopping until the review comes back clean of Critical and substantive non-blocking findings, or 3 iterations elapse. Stop once, after the final review output, and report every iteration's verdict plus the commits each produced.

Re-run `references/cross-workflow-coordination.md` when the task is a Linear issue at exactly three points: Step 0 intake, stage 9 (after the Decisions Checkpoint), and the atomic block's own final checkpoint after review — not at every stage, since stages 1-8 no longer stop.

## The Decisions Checkpoint must report

- every stage 1-8 completed, with artifact path(s)
- every provisional decision: stage, question, options considered, recommendation chosen, evidence — for the user to confirm or override
- factual assumptions recorded along the way
- when migrations are in scope: the migration-history artifact, every environment/history in the compatibility matrix, validation status, and any user-directed override
- cross-workflow status from intake (siblings checked, or "no Linear issue") — the pre-implementation gate itself hasn't run yet
- next stage (stage 9, the pre-implementation coordination check) and the exact resume command
- that this is a safe point to clear context

If the user overrides a provisional decision, update the ledger and re-run only the stages that decision invalidates before returning to this same checkpoint. Do not restart from stage 1. Do not run stage 9 before this checkpoint is confirmed, even if it would be convenient to front-load it.

## The stage-9 overlap stop (only if overlap is found) must report

- the specific sibling overlap: issue, files/requirement, options, recommendation, evidence
- that everything else (stages 1-8, Decisions Checkpoint) is already confirmed and unaffected
- next stage (the atomic block, once resolved) and the exact resume command

## The atomic block's final checkpoint must report

- every fix-loop iteration's verdict and the commits it produced
- the final review verdict
- cross-workflow re-check result (siblings may have advanced during implementation)
- whether context can be cleared safely

Resume by reading the workflow ledger first, then continue from the earliest incomplete stage. Do not re-run completed stages unless their input artifact changed or the user asks.

Implementation is a hard gate, not a default next action. Do not start `my-implement` unless the ledger explicitly marks all prior stages complete, every provisional decision was confirmed or overridden at the Decisions Checkpoint, `cross_workflow.pre_implementation_check` is `passed` for the current plan version (checked fresh after that checkpoint, never before), and the user resumed or explicitly requested implementation.
