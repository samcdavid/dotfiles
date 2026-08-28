---
model: opus
effort: xhigh
name: my-research
runner: skill-my-research
description: Deep codebase research with verified findings. Uses focused discovery agents, cross-checks claims against code, saves a durable research artifact, and records assumptions.
---

# Research Codebase

Use `skill-my-research` for the substantive, evidence-grounded research procedure. This wrapper resolves the request context, preserves the user-facing boundary, and presents the runner's compact result.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-research`.

- For a standalone request, derive `task` from `$ARGUMENTS` and the conversation; leave `stage` unset.
- `my-workflow` now uses `my-pair-plan` for collaborative planning and invokes
  focused discovery agents directly; it does not run this full research skill
  as a mandatory stage.
- If neither arguments nor context identifies a research subject, ask the user for the subject before dispatching.

The runner may create a local research artifact. In embedded mode it returns the stage outcome for `my-workflow` to record in the ledger; in standalone mode it may append to an existing ledger. It must return any outward-action request to this wrapper; do not infer permission to publish, send, push, or modify remote systems.

## Present

Apply `~/.claude/rules/human-readable-communication.md` (or `~/.agents/rules/`).
Return the runner's verified summary, research artifact path, assumptions, open questions, and compact decision/artifact envelope. Do not present unverified claims as findings.
