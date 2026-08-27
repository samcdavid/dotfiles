# Stage Routing

Load when starting or resuming `my-workflow`.

Read the workflow ledger first — detected primarily by the current git branch, per `references/protocol.md`'s Step 0. The ledger is the source of truth for completed stages. Loose artifacts can support a stage, but they do not mark that stage complete and they never authorize implementation by themselves.

## Migration Routing

Before choosing a route, inspect the task and any available diff for migration paths, version changes, schema/data migrations, or requests to repair a deployment database. If any are present — or if the impact on persisted data is uncertain — this is migration work. Read `migration-safety.md`, set `migration_safety: required` in the ledger, and route to the full pipeline. Never route migration work to `my-quick`, including a filename-only rename or retimestamp.

Default:

- No ledger (no branch match, and no Linear ID/ticket-slug/topic match): create one, recording the current branch, and run `my-research`, then continue into the next stage without stopping.
- Ledger exists: pick the earliest stage not marked `completed`. If it's stage 1-9, continue running from there through stage 9 without stopping, then stop at the Decisions Checkpoint. If stages 1-9 are already complete and confirmed but stage 10 hasn't run yet, run stage 10 next (not stages 1-9 again).

Quick handoff:

- If intake determines the task is small, well-understood, and better suited to `my-quick`, create/update the workflow ledger before handing off.
- Record `route: my-quick`, concise reason, expected scope, skipped full-pipeline rationale, and exact handoff command.
- Do not silently invoke `my-quick` without this ledger note.

Route to `my-quick` only when the change is a refactor (restructuring, extraction, inlining, reordering with no behavior change), a rename with no semantic change, a simplification or cleanup (dead code, verbose patterns, consistency), or a targeted fix in a clearly scoped, well-understood function. Migration work is excluded even if it otherwise looks like a rename. The test: an experienced engineer could predict the full before/after state without research.

Route to the full pipeline when the change adds new functionality, alters observable behavior callers depend on in ways needing contract analysis, fixes a bug that wants a new failing test to specify correct behavior, has significant blast radius (many callers, multiple modules, data migrations), or is architecturally significant (new pattern, changed module boundary, new dependency).

State the route and the one-sentence reason before running either path.

Run stages in this order, based on ledger status. Stages 1-9 run back-to-back with no stop; each writes its artifact and any provisional decision to the ledger, then the pipeline moves straight to the next stage:

## Embedded runner dispatch

`my-workflow` remains the skill-level coordinator. For a migrated stage, dispatch its named runner in **embedded mode** with `{ task, artifact_inputs, ledger_path, stage, authority: local_only }`, consume only its compact result envelope, and update the ledger itself. During rollout, when a named runner does not exist, invoke the stage's normal Skill entrypoint with the same inputs instead. Never pass raw subagent transcripts between stages.

| Stage wrapper | Runner when available | Fallback during rollout |
| --- | --- | --- |
| `my-research` | `skill-my-research` | `my-research` Skill entrypoint |
| `my-spec` | `skill-my-spec` | `my-spec` Skill entrypoint |
| `my-clarify` | `skill-my-clarify` | `my-clarify` Skill entrypoint |
| `my-architecture-plan` | `skill-my-architecture-plan` | `my-architecture-plan` Skill entrypoint |
| `my-test-strategy` | `skill-my-test-strategy` | `my-test-strategy` Skill entrypoint |
| `my-plan` | `skill-my-plan` | `my-plan` Skill entrypoint |
| `my-observe` | `skill-my-observe` | `my-observe` Skill entrypoint |
| `my-eval-plan` | `skill-my-eval-plan` | `my-eval-plan` Skill entrypoint |
| `my-analyze` | `skill-my-analyze` | `my-analyze` Skill entrypoint |
| `my-implement` | `skill-my-implement` | `my-implement` Skill entrypoint |
| `my-validate` | `skill-my-validate` | `my-validate` Skill entrypoint |
| `my-review` | `skill-my-review` | `my-review` Skill entrypoint |
| `implement-review` | `skill-implement-review` | `implement-review` Skill entrypoint |
| `address-pr-feedback local` | `skill-address-pr-feedback` | `address-pr-feedback` Skill entrypoint |

- `my-research` not completed: run `my-research`, log the artifact, continue.
- `my-spec` not completed: run `my-spec`, log the artifact and any provisional decision, continue.
- `my-clarify` not completed: run `my-clarify`, feed resolutions into spec, log any provisional decision, continue.
- `my-architecture-plan` not completed: run `my-architecture-plan`, log the artifact and any provisional decision, continue.
- `my-test-strategy` not completed: run `my-test-strategy`, passing the clarified spec, research, and architecture artifacts; log its behavior-to-test artifact and any provisional decision, continue.
- `my-plan` not completed: run `my-plan`, passing the architecture and test-strategy paths so it seeds `## Architectural Constraints` and behavior-first `Tests First (RED)` from them; log the artifact and any provisional decision, continue.
- `my-observe` not completed: run `my-observe`, log the artifact, continue.
- `my-eval-plan` unset: decide applicability. If the plan touches an AI/LLM surface (prompts, system messages, tool docstrings, model or retrieval selection, scoring, or model-produced behavior), run `my-eval-plan` and log the artifact. Otherwise mark it `not_applicable` with a one-line reason. Either way, continue without stopping.
- `my-analyze` not completed: run `my-analyze`, including the test-strategy artifact, log the artifact, then **stop here** at the Decisions Checkpoint — present every stage 1-9 artifact plus every accumulated provisional decision for the user to confirm or override. This is the point to clear context; do not run stage 10 yet.
- Decisions Checkpoint confirmed (every provisional decision resolved), and `pre_implementation_check` is unset or `not_run` for the current plan version, and the task is a Linear issue: run the Pre-Implementation Gate in `references/cross-workflow-coordination.md` — fresh sibling ledger/issue scan against the finalized plan's surfaces. If it finds overlap, stop with just that decision (options, recommendation, evidence). If clear, ledger `passed`. Not a Linear issue: ledger `passed` (not applicable).
- Implementation gate satisfied and explicit implementation authorization
  present: dispatch `my-implement` in embedded mode with the approved plan, test
  strategy, and ledger context. Do not dispatch `implement-review` yet. Mark the
  implementation stage complete only when every phase is committed, the plan is
  `implemented`, and its holistic test gate passes; otherwise stop with the
  runner's blocker.
- Implementation stage completed: dispatch `implement-review` in embedded mode
  with the completed implementation evidence, approved artifacts, base, and
  ledger context. It owns only whole-branch review and bounded repair. It must
  not dispatch `my-implement` or finish an incomplete plan.

`implement-review` has one cap of 5 post-implementation review passes. Its pass
counter begins only after `my-implement` completes. A `clean` result proceeds to
the final checkpoint. `blocked` or `cap_reached` stops with surviving findings,
iteration deltas, repair commits, and root-cause theory. Nits and clearly
optional suggestions are deferred without another pass.

Review-loop gate:

- The ledger marks `my-implement` completed for the current plan version.
- Every plan phase/checklist item is complete and plan status is `implemented`.
- The `my-implement` envelope records all phase commits and a successful holistic
  test gate.
- Missing or failed evidence blocks `implement-review` without consuming pass 1.

Legacy ledger compatibility: a previously completed clean atomic
`implement-review` stage satisfies both stages 11 and 12. For an old incomplete
atomic stage, inspect the plan. If any implementation remains, record the route
migration and resume at stage 11 `my-implement`; do not continue the old nested
loop or count pre-completion review attempts against stage 12's pass budget.

Implementation gate:

- The ledger must explicitly mark `my-research`, `my-spec`, `my-clarify`, `my-architecture-plan`, `my-test-strategy`, `my-plan`, `my-observe`, and `my-analyze` as `completed`, and `my-eval-plan` as either `completed` or `not_applicable`.
- The ledger must contain artifact paths for the research, spec, architecture plan, test strategy, plan, observability, and analysis outputs, plus the eval plan when `my-eval-plan` is `completed`.
- Every entry under `## Provisional Decisions` must be confirmed or overridden at the Decisions Checkpoint — an unconfirmed provisional decision blocks stage 10 and implementation the same way an incomplete stage does.
- `cross_workflow.pre_implementation_check` must be `passed` for the current plan version, checked fresh *after* the Decisions Checkpoint — `not_run`, unset, or `overlap_pending` all block implementation the same way an incomplete stage does. A check run before the Decisions Checkpoint (or reused from an earlier one) does not satisfy this gate.
- When `migration_safety: required`, the ledger must link a completed migration-history audit and compatibility matrix, and record successful validation for every planned database history. `blocked`, `failed`, `unrun`, or missing validation blocks implementation. A user-directed override may permit an action, but does not change the gate to passed.
- The current invocation must be a resume after the user confirmed or overrode every provisional decision at the Decisions Checkpoint, or must explicitly say to proceed with implementation.

If any gate is missing, do not implement. Run the earliest missing stage or checkpoint with the missing ledger/artifact requirement.

Skipped stages require a current artifact and a ledger note explaining why. Do not skip `my-research` on a new workflow.
