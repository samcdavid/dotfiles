---
model: sonnet
effort: high
name: quality-audit
runner: skill-quality-audit
description: Deep audit of test quality, coverage fidelity, flakiness risk, assertions, mocks, and whether tests actually catch intended bugs.
disallowed-tools: Edit, Write, NotebookEdit
---

# Quality Audit

Use `skill-quality-audit` for the substantive dedicated test-quality audit. This wrapper resolves the scope and review mode, keeps the user-facing boundary, and presents the runner's evidence-backed audit envelope.

## Dispatch

Normalize the request into `{ target, mode, artifact_inputs, authority: local_only }` and dispatch it to `skill-quality-audit`.

- Derive `mode` as PR, diff/range, local path, plan/spec, or feature area. Ask for a target only when none can be inferred.
- The runner uses the retained shared checklist at `references/protocol.md`, delegates substantive assessment to `quality-reviewer`, and returns any external-action intent rather than performing it.

## Present

Return material findings with file:line evidence, escape path, stronger-test recommendation, coverage/fidelity assessment, dismissed concerns, residual unknowns, and the compact audit envelope. Do not include raw subagent transcripts.
