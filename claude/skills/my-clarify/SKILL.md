---
model: sonnet
effort: high
name: my-clarify
runner: skill-my-clarify
description: Surface ambiguities, contradictions, hidden assumptions, and underspecified areas in specs or research before planning.
---

# Clarify

Use `skill-my-clarify` for the substantive ambiguity review. This wrapper resolves the target and preserves the user-facing decision boundary while the runner returns a compact clarification envelope.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-clarify`.

- For a standalone request, derive `task` from `$ARGUMENTS` and the conversation; leave `stage` unset.
- `my-workflow` now resolves ambiguity live through `my-pair-plan`; it does not
  run this standalone clarification artifact stage.
- If no target document can be inferred from arguments or context, ask the user which document to clarify before dispatching.

In embedded mode the runner returns local resolutions for `my-workflow` to record in the ledger; in standalone mode it may append to an existing ledger. It must return any request to edit a source document, create or update remote content, post, send, publish, or push to this wrapper for explicit authorization.

## Present

Apply `~/.claude/rules/human-readable-communication.md` (or `~/.agents/rules/`).
Return the issues grouped by severity, document locations, why each matters, suggested resolutions, assumptions, provisional decisions, and compact decision/artifact envelope.
