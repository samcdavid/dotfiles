## Step 2 — Spawn the investigator

Invoke the `runtime-investigator` agent with the bundle:

```
- symptom
- started_at (if provided or inferable from artifacts; null otherwise)
- blast_radius_hint (if volunteered by user; null otherwise)
- ci_issue: true/false
- observability_tools: list of {name, access_method} (pass what the user mentioned; agent discovers the rest)
- relevant_service (if known or inferable; null otherwise)
- relevant_code_paths (if provided; null otherwise)
- linked_artifacts: alert URLs, trace IDs, dashboards, tickets, error messages
```

The agent discovers accessible observability tools, builds a timeline, narrows the blast radius, checks for flaky tests (if CI), traces the request path, tests hypotheses, and returns structured evidence + a ranked hypothesis list + any targeted questions.

If the agent returns an `## Error` block (genuine access failure after discovery attempts), surface it and stop.
