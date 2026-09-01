---
model: sonnet
effort: high
name: my-architecture-plan
runner: skill-my-architecture-plan
description: Plan the architectural shape of a change before implementation — module placement, coupling and cohesion, boundary and dependency design, and any deliberate deviation from convention — so my-plan's phases and my-implement's code land in the right structure the first time.
---

# Architecture Plan

Use `skill-my-architecture-plan` for the substantive structural-design procedure. This wrapper resolves the request, preserves the user-facing decision boundary, and presents the runner's compact artifact envelope.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-architecture-plan`.

- For a standalone request, derive `task` from `$ARGUMENTS` and the conversation; leave `stage` unset.
- `my-workflow` invokes the runner's `focused_advisory` mode only when its
  planning conversation exposes a material architecture uncertainty; this
  standalone wrapper still creates a full architecture artifact when requested.
- If no task can be inferred from arguments, context, or linked artifacts, ask the user for the change to design before dispatching.

The runner may create a local architecture artifact. In embedded mode it returns the stage outcome for `my-workflow` to record; in standalone mode it may append to an existing ledger. It must return any outward-action request to this wrapper; do not infer permission to publish, send, push, or modify remote systems.

## Present

Apply `~/.claude/rules/human-readable-communication.md` (or `~/.agents/rules/`).
Return the architecture-plan path, proposed placement, falsifiable constraints, flagged deviations, assumptions, provisional decisions, recommended next command, and compact decision/artifact envelope.
