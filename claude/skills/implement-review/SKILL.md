---
model: sonnet
effort: high
name: implement-review
runner: skill-implement-review
description: Execute an approved plan through implementation, validation, whole-branch review, and bounded repair until clean or a five-pass cap.
---

# Implement and Review

Use `skill-implement-review` for the atomic local delivery loop. It is the only
owner of iteration counting and terminal clean-state claims. It coordinates the
existing implementation executors and review agents; do not run a nested
`my-review` or feedback repair loop inside it.

## Dispatch

Normalize input into `{ mode, plan_path, artifact_inputs, base_ref, ledger_path,
stage, authority: local_only }` and dispatch it to `skill-implement-review`.

- `mode` is `standalone` or `embedded`. Embedded callers supply the approved
  plan, test strategy, base, ledger, and stage context.
- Require an approved plan with RED tests and success criteria before dispatch.
- The runner may make only locally validated, committed changes through
  `implementation-executor` or `quick-implement-agent`. It never pushes,
  publishes, opens or updates a PR, or makes another outward action.

## Present

Return implementation commits, each review-pass result, repairs, validation
evidence, final status (`clean`, `blocked`, or `cap_reached`), surviving
findings, and the workflow-stage envelope when embedded. A branch is ready only
when the final whole-branch review is clean; a cap-reached run is not completion.
