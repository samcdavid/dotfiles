---
model: sonnet
effort: high
name: implement-review
runner: skill-implement-review
description: Review and repair completed implementation through a bounded local loop until clean or a five-pass cap.
---

# Review and Repair

Use `skill-implement-review` only after planned implementation is complete. It
owns review/repair iteration counting and terminal clean-state claims, but never
owns initial plan execution. Run `my-implement` first for an unfinished approved
plan. Do not run a nested `my-review` or feedback repair loop inside it.

## Dispatch

Normalize input into `{ mode, plan_path, artifact_inputs, base_ref, ledger_path,
stage, authority: local_only }` and dispatch it to `skill-implement-review`.

- `mode` is `standalone` or `embedded`. Embedded callers supply the approved
  plan, test strategy, base, ledger, and stage context.
- When a plan is supplied, require proof that `my-implement` completed every
  phase and its holistic test gate. If any phase remains unfinished, return
  `blocked` with the exact `/my-implement <plan>` handoff; never execute it here.
- With completed planned work or unplanned existing work, start with a
  whole-branch review, then repair only verified substantive findings within the
  five-pass budget. Do not reject review merely because no plan exists.
- The runner may make only locally validated, committed changes through
  `implementation-executor` or `quick-implement-agent`. It never pushes,
  publishes, opens or updates a PR, or makes another outward action.

## Present

Return the supplied implementation evidence, each review-pass result, repairs,
validation evidence, final status (`clean`, `blocked`, or `cap_reached`),
surviving findings, and the workflow-stage envelope when embedded. A branch is
ready only when the final whole-branch review is clean; a cap-reached run is not
completion.
