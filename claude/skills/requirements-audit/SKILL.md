---
model: sonnet
effort: high
name: requirements-audit
runner: skill-requirements-audit
description: Audit a PR, ticket, spec, or local change against stated requirements and acceptance criteria.
disallowed-tools: Edit, Write, NotebookEdit
---

# Requirements Audit

Use `skill-requirements-audit` for the substantive dedicated traceability audit. This wrapper resolves the implementation target and requirements source, keeps the user-facing boundary, and presents the runner's evidence-backed audit envelope.

## Dispatch

Normalize the request into `{ target, mode, requirements_source, artifact_inputs, authority: local_only }` and dispatch it to `skill-requirements-audit`.

- Derive `mode` as PR, diff/range, ticket, spec, plan, or local target. Ask for a source of truth only when it cannot be found in supplied context or linked artifacts.
- The runner uses the retained shared checklist at `references/protocol.md`, delegates substantive traceability to `requirements-reviewer`, and returns any external-action intent rather than performing it.

## Present

Return the requirements map, traceability matrix, findings with requirement/code/test evidence, scope analysis, dismissed concerns, residual unknowns, and the compact audit envelope. Do not include raw subagent transcripts.
