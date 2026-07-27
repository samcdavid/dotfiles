# Checkpoint Policy

Load before ending any `my-workflow` stage.

Stop after every stage except inside the atomic execution/review block:

- Stage 1 `my-research` -> stop.
- Stage 2 `my-spec` -> stop.
- Stage 3 `my-clarify` -> stop.
- Stage 4 `my-plan` -> stop; do not implement until user resumes.
- Stage 5 `my-observe` -> stop.
- Stage 6 `my-eval-plan` -> stop when it ran; continue without stopping when ledgered `not_applicable`.
- Stage 7 `my-analyze` -> stop.
- Atomic block `my-implement` -> fix loop -> stop after the final review output.

The fix loop is **not** checkpointed per iteration. `my-validate` -> `my-review` -> `address-pr-feedback local` repeats without stopping until the review comes back clean of Critical and substantive non-blocking findings, or 3 iterations elapse. Stop once, after the final review output, and report every iteration's verdict plus the commits each produced.

Every checkpoint must update the workflow ledger and report:

- stage completed
- artifact path(s)
- decisions still needed, if any
- assumptions recorded
- next stage
- exact resume command
- whether context can be cleared safely

Resume by reading the workflow ledger first, then continue from the earliest incomplete stage. Do not re-run completed stages unless their input artifact changed or the user asks.

Implementation is a hard gate, not a default next action. Do not start `my-implement` unless the ledger explicitly marks all prior stages complete and the user resumed after reviewing the plan/analysis checkpoints or explicitly requested implementation.
