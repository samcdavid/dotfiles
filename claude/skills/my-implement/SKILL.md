---
model: sonnet
effort: high
name: my-implement
runner: skill-my-implement
description: Execute an approved plan phase by phase through a model-pinned runner that dispatches one implementation executor at a time, enforces RED -> GREEN -> VALIDATE, and preserves the commit and workflow boundaries.
---

# Implement Plan

Use `skill-my-implement` for the substantive, sequential plan-execution procedure. This wrapper resolves the approved plan and embedded workflow context, keeps authorization and presentation at the user-facing boundary, and returns the runner's compact execution envelope.

## Dispatch

Normalize the request into `{ mode, plan_path, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-implement`.

- For a standalone request, derive `plan_path` from `$ARGUMENTS`. If it is absent, list plans in `~/.claude/thoughts/shared/plans/` and ask the user which approved plan to execute.
- For `/my-workflow`, preserve the approved plan path, supplied artifact inputs, ledger path, and stage number, and dispatch in embedded mode. The runner returns the stage outcome for `my-workflow` to record; it does not claim workflow completion itself.
- Do not dispatch if the plan has no RED tests or success criteria for its next unfinished phase.

The runner may make locally validated implementation changes only through its `implementation-executor` / `Skill(commit)` path. It must return any external action request to this wrapper; never infer authorization to push, publish, create or update a PR, or otherwise change a remote system.

## Present

Return completed phases, commit SHAs, holistic verification evidence, deviations,
uncommitted or escalated work, the workflow-stage envelope when embedded, and
the recommended next command: `implement-review` only after every implementation
phase is complete. Do not include raw executor transcripts.
