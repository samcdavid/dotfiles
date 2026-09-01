---
model: sonnet
effort: high
name: my-plan
runner: skill-my-plan
description: Create a detailed implementation plan with mechanically verifiable success criteria, phase boundaries, tests-first steps, and explicit non-goals.
---

# Create Plan

Use `skill-my-plan` for the substantive implementation-planning procedure. This wrapper resolves the request, preserves the user-facing decision boundary, and presents the runner's compact plan envelope.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-plan`.

- For a standalone request, derive `task` from `$ARGUMENTS` and the conversation; leave `stage` unset.
- `my-workflow` now builds implementation phases interactively in
  `my-pair-plan`'s living ledger; it does not run this standalone plan artifact
  stage.
- If no task can be inferred from arguments, context, or linked artifacts, ask the user for the work to plan before dispatching.

The runner may create a local implementation plan. In embedded mode it returns the stage outcome for `my-workflow` to record; in standalone mode it may append to an existing ledger. It must return any outward-action request to this wrapper; do not infer permission to publish, send, push, or modify remote systems.

## Present

Apply `~/.claude/rules/human-readable-communication.md` (or `~/.agents/rules/`).
Return the plan path, phase summary, mechanical success criteria, architectural constraints, assumptions, provisional decisions, observability recommendation, recommended next command, and compact decision/artifact envelope.
