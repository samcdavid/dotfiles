# Stage Routing

Load when starting or resuming `my-workflow`.

Read the workflow ledger first. The ledger is the source of truth for completed stages. Loose artifacts can support a stage, but they do not mark that stage complete and they never authorize implementation by themselves.

Default:

- No ledger: create one and run `my-research`, then checkpoint.
- Ledger exists: pick the earliest stage not marked `completed`.

Quick handoff:

- If intake determines the task is small, well-understood, and better suited to `my-quick`, create/update the workflow ledger before handing off.
- Record `route: my-quick`, concise reason, expected scope, skipped full-pipeline rationale, and exact handoff command.
- Do not silently invoke `my-quick` without this ledger note.

Run stages in this order, based on ledger status:

- `my-research` not completed: run `my-research`, then checkpoint.
- `my-spec` not completed: run `my-spec`, then checkpoint.
- `my-clarify` not completed: run `my-clarify`, feed resolutions into spec, then checkpoint.
- `my-plan` not completed: run `my-plan`, then checkpoint before implementation.
- `my-observe` not completed: run `my-observe`, then checkpoint.
- `my-analyze` not completed: run `my-analyze`, then checkpoint.
- Implementation not reviewed, and implementation gate is satisfied: run atomic block `my-implement` -> `my-validate` -> `my-review`, then checkpoint.
- Review has findings and user resumed for fixes: run one post-review loop iteration `address-pr-feedback` -> `my-validate` -> `my-review`, then checkpoint.

Implementation gate:

- The ledger must explicitly mark `my-research`, `my-spec`, `my-clarify`, `my-plan`, `my-observe`, and `my-analyze` as `completed`.
- The ledger must contain artifact paths for the research, spec, plan, observability, and analysis outputs.
- The current invocation must be a resume after the plan/analysis checkpoints or must explicitly say to proceed with implementation.

If any gate is missing, do not implement. Run the earliest missing stage or checkpoint with the missing ledger/artifact requirement.

Skipped stages require a current artifact and a ledger note explaining why. Do not skip `my-research` on a new workflow.
