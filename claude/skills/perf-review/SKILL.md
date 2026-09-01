---
model: sonnet
effort: high
name: perf-review
runner: skill-perf-review
description: "Deep performance review: query plans, index coverage, load impact, caching strategy, resource use, and scaling risks."
disallowed-tools: Edit, Write, NotebookEdit
---

# Performance Review

Use `skill-perf-review` for the substantive dedicated performance audit. This wrapper resolves the scope and review mode, keeps the user-facing boundary, and presents the runner's evidence-backed audit envelope.

## Dispatch

Normalize the request into `{ target, mode, workload_context, artifact_inputs, authority: local_only }` and dispatch it to `skill-perf-review`.

- Derive `mode` as PR, diff/range, local path, or feature area. Ask for a target only when none can be inferred.
- Preserve supplied load, cardinality, latency, or deployment context without inventing production facts.
- The runner uses the retained shared checklist at `references/protocol.md`, delegates substantive assessment to `perf-reviewer`, and returns any external-action intent rather than performing it.

## Present

Return material findings with bottleneck, reachable scale condition, code evidence, expected impact, concrete remediation, dismissed concerns, residual unknowns, and the compact audit envelope. Do not include raw subagent transcripts.
