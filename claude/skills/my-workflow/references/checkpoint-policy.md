# Checkpoint Policy

Load before ending any `my-workflow` stage.

Stop after every stage except inside the atomic execution/review block:

- Stage 1 `my-research` -> stop.
- Stage 2 `my-spec` -> stop.
- Stage 3 `my-clarify` -> stop.
- Stage 4 `my-plan` -> stop; do not implement until user resumes.
- Stage 5 `my-observe` -> stop.
- Stage 6 `my-analyze` -> stop.
- Atomic block `my-implement` -> `my-validate` -> `my-review` -> stop after review output.

Post-review fixes are checkpointed by review pass: when the user resumes to address findings, run one loop iteration `address-pr-feedback` -> `my-validate` -> `my-review`, then stop after the new review output.

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
