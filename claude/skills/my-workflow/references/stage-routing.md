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

Route to `my-quick` when the change is a refactor (restructuring, extraction, inlining, reordering with no behavior change), a rename with no semantic change, a simplification or cleanup (dead code, verbose patterns, consistency), or a targeted fix in a clearly scoped, well-understood function. The test: an experienced engineer could predict the full before/after state without research.

Route to the full pipeline when the change adds new functionality, alters observable behavior callers depend on in ways needing contract analysis, fixes a bug that wants a new failing test to specify correct behavior, has significant blast radius (many callers, multiple modules, data migrations), or is architecturally significant (new pattern, changed module boundary, new dependency).

State the route and the one-sentence reason before running either path.

Run stages in this order, based on ledger status:

- `my-research` not completed: run `my-research`, then checkpoint.
- `my-spec` not completed: run `my-spec`, then checkpoint.
- `my-clarify` not completed: run `my-clarify`, feed resolutions into spec, then checkpoint.
- `my-plan` not completed: run `my-plan`, then checkpoint before implementation.
- `my-observe` not completed: run `my-observe`, then checkpoint.
- `my-eval-plan` unset: decide applicability. If the plan touches an AI/LLM surface (prompts, system messages, tool docstrings, model or retrieval selection, scoring, or model-produced behavior), run `my-eval-plan`, then checkpoint. Otherwise mark it `not_applicable` with a one-line reason and continue without stopping.
- `my-analyze` not completed: run `my-analyze`, then checkpoint.
- Implementation not reviewed, and implementation gate is satisfied: run the atomic block — `my-implement`, then the fix loop — then checkpoint.

Fix loop (runs automatically, no checkpoint between iterations):

1. `my-validate`.
2. `my-review` in local mode against the base branch.
3. Decide: if the review yields Critical findings, or non-blocking findings substantive enough that shipping them would be sloppy, run `address-pr-feedback local` with those findings passed inline, then go back to step 1. Otherwise exit the loop.
4. Hard cap: 3 iterations. On the 3rd review still having Critical findings, stop and checkpoint with the surviving findings and a root-cause theory — that is a genuine blocker, not something to keep grinding on.

Nits and clearly optional suggestions never justify another iteration; carry them into the checkpoint as deferred items. Do not re-run earlier pipeline stages from inside this loop.

Implementation gate:

- The ledger must explicitly mark `my-research`, `my-spec`, `my-clarify`, `my-plan`, `my-observe`, and `my-analyze` as `completed`, and `my-eval-plan` as either `completed` or `not_applicable`.
- The ledger must contain artifact paths for the research, spec, plan, observability, and analysis outputs, plus the eval plan when `my-eval-plan` is `completed`.
- The current invocation must be a resume after the plan/analysis checkpoints or must explicitly say to proceed with implementation.

If any gate is missing, do not implement. Run the earliest missing stage or checkpoint with the missing ledger/artifact requirement.

Skipped stages require a current artifact and a ledger note explaining why. Do not skip `my-research` on a new workflow.
