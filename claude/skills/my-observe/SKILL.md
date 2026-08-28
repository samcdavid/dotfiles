---
model: sonnet
effort: high
name: my-observe
runner: skill-my-observe
description: "Design observability and monitoring for planned code changes: metrics, traces, spans, logs, dashboards, and actionable alerts."
---

# Observe

Use `skill-my-observe` for the substantive observability-design procedure. This wrapper resolves the target, preserves user-facing decisions and external-action boundaries, and presents the runner's compact companion-plan envelope.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-observe`.

- For a standalone request, derive `task` from `$ARGUMENTS` and the conversation; leave `stage` unset.
- `my-workflow` invokes the runner's `focused_advisory` mode only when its
  planning conversation identifies runtime observability or rollout needs.
- If no target plan, change, or system can be inferred, ask the user what to observe before dispatching.

The runner may create a local observability companion artifact. In embedded mode it returns the stage outcome for `my-workflow` to record; in standalone mode it may append to an existing ledger. It must return any external configuration, publication, or notification request to this wrapper for explicit authorization.

## Present

Return the observability-plan path, recommended signals, alert criteria, dashboard ideas, validation checks, assumptions, provisional decisions, and compact decision/artifact envelope.
