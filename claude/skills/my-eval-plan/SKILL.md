---
model: sonnet
effort: high
name: my-eval-plan
runner: skill-my-eval-plan
description: "Design evaluation plans for AI/LLM features: datasets, scorers, baselines, success criteria, and regression strategy."
---

# Eval Plan

Use `skill-my-eval-plan` for the substantive AI/LLM evaluation-planning procedure. This wrapper resolves the target, preserves user-facing decisions and external-action boundaries, and presents the runner's compact evaluation envelope.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-eval-plan`.

- For a standalone request, derive `task` from `$ARGUMENTS` and the conversation; leave `stage` unset.
- For `/my-workflow`, preserve supplied artifact inputs, ledger path, and stage number, and dispatch in embedded mode. The runner records genuine quality-bar or launch choices as provisional decisions instead of stopping the pipeline.
- If no AI/LLM feature can be inferred from context or linked artifacts, ask the user for the feature to evaluate before dispatching.

The runner may create a local evaluation-plan artifact. In embedded mode it returns the stage outcome for `my-workflow` to record; in standalone mode it may append to an existing ledger. It must return any external dataset, vendor, publication, or notification request to this wrapper for explicit authorization.

## Present

Return the evaluation-plan path, scorer definitions, dataset plan, baseline targets, instrumentation needs, assumptions, provisional decisions, and compact decision/artifact envelope.
