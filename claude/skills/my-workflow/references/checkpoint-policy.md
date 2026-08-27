# Checkpoint Policy

Load before ending any `my-workflow` stage.

There are three possible stops in the whole pipeline; only two are guaranteed. Everything else runs straight through:

- Stages 1-9 (`my-research`, `my-spec`, `my-clarify`, `my-architecture-plan`, `my-test-strategy`, `my-plan`, `my-observe`, `my-eval-plan` when applicable, `my-analyze`) -> continue automatically. Update the ledger silently: status, artifact path, factual assumptions, and any provisional decision (options, recommendation chosen, evidence). Do not stop.
- **Decisions Checkpoint**, after stage 9 -> always stop, guaranteed. Present every artifact from stages 1-9 and every provisional decision logged along the way together, so the user can confirm or override. This is the deliberate point to clear context — resuming reads the ledger and continues from here. Nothing runs stage 10 or touches `my-implement` before this stop happens and the user resumes past it.
- Stage 10, Pre-implementation coordination check -> runs only after the Decisions Checkpoint is confirmed. Stop only if it finds a sibling overlap.
- Stage 11 (`my-implement`) -> complete all implementation without review-loop
  passes. Stop only if implementation blocks; otherwise continue to stage 12.
- Stage 12 (`implement-review`) -> begin the review/repair loop only after stage
  11 is recorded complete, then stop after its terminal envelope.

Implementation and review are not interleaved. Stage 11 finishes the complete
`my-implement` plan first. Stage 12 then runs `my-review` -> bounded repair ->
`my-validate` -> `my-review` without checkpointing each iteration, until clean or
5 review passes elapse. `blocked` and `cap_reached` are incomplete outcomes.

Re-run `references/cross-workflow-coordination.md` when the task is a Linear issue at exactly three points: Step 0 intake, stage 10, and stage 12's final checkpoint after review—not between implementation phases or repair passes.

## The Decisions Checkpoint must report

- every stage 1-9 completed, with artifact path(s), including the behavior-first test strategy
- every provisional decision: stage, question, options considered, recommendation chosen, evidence — for the user to confirm or override
- factual assumptions recorded along the way
- when migrations are in scope: the migration-history artifact, every environment/history in the compatibility matrix, validation status, and any user-directed override
- cross-workflow status from intake (siblings checked, or "no Linear issue") — the pre-implementation gate itself hasn't run yet
- next stage (stage 10, the pre-implementation coordination check) and the exact resume command
- that this is a safe point to clear context

If the user overrides a provisional decision, update the ledger and re-run only the stages that decision invalidates before returning to this same checkpoint. Do not restart from stage 1. Do not run stage 10 before this checkpoint is confirmed, even if it would be convenient to front-load it.

## The stage-10 overlap stop (only if overlap is found) must report

- the specific sibling overlap: issue, files/requirement, options, recommendation, evidence
- that everything else (stages 1-9, Decisions Checkpoint) is already confirmed and unaffected
- next stage (`my-implement`, once resolved and authorized) and the exact resume command

## Stage 12's final checkpoint must report

- stage 11 implementation completion, phase commits, and holistic test evidence
- every stage 12 repair-loop iteration's verdict and commits
- the final review verdict
- cross-workflow re-check result (siblings may have advanced during implementation)
- whether context can be cleared safely

Resume by reading the workflow ledger first, then continue from the earliest incomplete stage. Do not re-run completed stages unless their input artifact changed or the user asks.

Implementation is a hard gate, not a default next action. Do not start `my-implement` unless the ledger explicitly marks all prior stages complete, every provisional decision was confirmed or overridden at the Decisions Checkpoint, `cross_workflow.pre_implementation_check` is `passed` for the current plan version (checked fresh after that checkpoint, never before), and the user resumed or explicitly requested implementation.
