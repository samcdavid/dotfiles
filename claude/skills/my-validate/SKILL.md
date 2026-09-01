---
model: sonnet
effort: high
name: my-validate
runner: skill-my-validate
description: Validate work against a plan or current session through a model-pinned runner that runs mechanical checks, verifies claims against code, repairs scoped local failures safely, and reports residual risk.
---

# Validate

Use `skill-my-validate` for the substantive validation and safe-local-repair procedure. This wrapper resolves plan or session mode, preserves authorization and workflow ledger ownership, and presents the runner's compact validation envelope.
Use `~/.claude/rules/verification-ladder.md` (or `~/.agents/rules/`) for repair checks.

## Dispatch

Normalize the request into `{ mode, plan_path, artifact_inputs, base_ref, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-validate`.

- A plan path selects **plan** mode. Otherwise use **session** mode for current conversation claims and working-tree changes.
- For `/my-workflow`, preserve its plan/base/ledger context and stage number, and dispatch in embedded mode. The runner returns its outcome for `my-workflow` to record rather than marking the workflow ledger complete itself.
- Ask only when neither plan nor current-session evidence makes a mode safe to infer.

The runner may delegate only obvious, scoped local repairs through `my-implement`, then must independently validate each result. It must return any request to push, publish, create or update a PR, send, or otherwise change a remote system to this wrapper for explicit authorization.

## Present

Apply `~/.claude/rules/human-readable-communication.md` (or `~/.agents/rules/`).
Return checks and coverage, repairs and local commit SHAs with their subjects and
effects, residual risks, blockers, report/artifact paths, and the workflow-stage
envelope when embedded. Expand every internal status/key. Do not include raw
tool transcripts.
