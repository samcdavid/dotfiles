---
model: sonnet
effort: xhigh
name: my-investigate
runner: skill-my-investigate
description: Investigate production, runtime, CI, or test issues by gathering evidence from logs, metrics, traces, code, and CI, then ranking hypotheses.
disable-model-invocation: false
---

# Investigate

Use `skill-my-investigate` for the substantive read-only runtime or CI investigation. This wrapper normalizes the incident context, preserves the user-facing mitigation boundary, and presents the runner's evidence envelope.

## Dispatch

Normalize the request into `{ symptom, started_at, blast_radius_hint, ci_issue, relevant_service, relevant_code_paths, linked_artifacts, authority: local_only }` and dispatch it to `skill-my-investigate`.

- Infer CI mode from test, build, pipeline, or flaky-test symptoms; do not ask the user to name observability tools.
- Ask only for missing context that cannot be discovered and materially changes the investigation.
- The runner delegates evidence gathering and hypothesis ranking to `runtime-investigator`; it never mitigates, edits, deploys, restarts, or changes infrastructure.

## Present

Return verified timeline and blast radius, ranked hypotheses with evidence for and against, targeted questions, read-only next checks, and mitigation/fix options for the user to decide. Do not include raw investigator transcripts.
