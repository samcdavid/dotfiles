---
model: opus
effort: high
name: my-analyze
runner: skill-my-analyze
description: Compare research, specs, plans, and related artifacts to find contradictions, coverage gaps, scope drift, and implementation-readiness risks.
---

# Analyze

Use `skill-my-analyze` for the substantive cross-artifact consistency procedure. This wrapper resolves the artifacts, preserves the user-facing decision boundary, and presents the runner's compact analysis envelope.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-analyze`.

- For a standalone request, derive `task` and artifact inputs from `$ARGUMENTS` and the conversation; leave `stage` unset.
- For `/my-workflow`, preserve supplied artifact inputs, ledger path, and stage number, and dispatch in embedded mode. The runner records genuine artifact conflicts as recommended provisional decisions instead of stopping the pipeline.
- If fewer than two artifacts can be inferred, ask the user to identify them or recommend `/my-clarify` before dispatching.

The runner may create a local analysis report. In embedded mode it returns the stage outcome for `my-workflow` to record; in standalone mode it may append to an existing ledger. It must return any outward-action request to this wrapper; do not infer permission to publish, send, push, or modify remote systems.

## Present

Return the analysis-report path, consistency findings with artifact references, recommended fixes, implementation-readiness assessment, assumptions, provisional decisions, and compact decision/artifact envelope.
