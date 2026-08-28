---
model: sonnet
effort: high
name: my-spec
runner: skill-my-spec
description: Refine vague ideas, bugs, or rough requests into scoped technical-product specs with problem statement, boundaries, acceptance criteria, and open decisions.
---

# Spec

Use `skill-my-spec` for the substantive product-spec procedure. This wrapper normalizes context, keeps user decisions and outward actions at the user-facing boundary, and presents the runner's decision/artifact envelope.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-spec`.

- For a standalone request, derive `task` from `$ARGUMENTS` and the conversation; leave `stage` unset.
- `my-workflow` now develops requirements interactively through `my-pair-plan`'s
  living ledger; it does not run this standalone spec artifact stage.
- If no task can be inferred from arguments or context, ask the user for the subject before dispatching.

The runner may create a local spec artifact. In embedded mode it returns the stage outcome for `my-workflow` to record in the ledger; in standalone mode it may append to an existing ledger. It must return any request to create or update a remote issue, post, send, publish, or push to this wrapper for explicit user authorization.

## Present

Return the spec path, concise summary, acceptance criteria, assumptions, open or provisional decisions, recommended next command, and compact decision/artifact envelope.
