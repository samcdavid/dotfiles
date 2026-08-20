---
model: sonnet
effort: high
name: my-arch-review
runner: skill-my-arch-review
description: Architecture review of a PR, document, or code area for boundaries, coupling, cohesion, dependency direction, and maintainability.
disallowed-tools: Edit, Write, NotebookEdit
---

# Architecture Review

Use `skill-my-arch-review` for the substantive architecture-audit procedure. This wrapper resolves the review target, keeps the user-facing boundary, and presents the runner's compact, evidence-backed result.

## Dispatch

Normalize the request into `{ target, mode, artifact_inputs, authority: local_only }` and dispatch it to `skill-my-arch-review`.

- Derive `mode` as PR, diff/range, local path, document, or feature area from the request and current context.
- If no review target can be inferred, ask the user what to review before dispatching.
- The runner uses the retained shared checklist at `references/protocol.md`, delegates substantive assessment to `arch-reviewer`, and returns any outward-action intent rather than performing it.

## Present

Return architecture context, material findings with file:line evidence, dependency/boundary assessment, recommended adjustments, dismissed concerns, residual questions, and the compact audit envelope. Do not include raw subagent transcripts.
