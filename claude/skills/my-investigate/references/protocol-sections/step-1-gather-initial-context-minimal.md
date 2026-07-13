## Step 1 — Gather initial context (minimal)

All you need to start is:

1. **Symptom** — errors, latency, data inconsistency, failing CI, alert text, error messages, trace IDs, dashboard URLs, ticket URLs

Everything else is either self-discoverable or the agent will surface it. Collect anything the user volunteers (timestamps, blast radius guesses, suspect code paths, observability tool names) but do not interrogate for items you can infer later.

**CI detection**: If the symptom mentions tests, CI, pipeline, build, spec, or flaky — mark `ci_issue: true`. The agent checks flaky tests and build logs before pursuing other angles.

**Do not ask for observability tool names.** The agent discovers available tools from MCP context. Ask only if the user references a specific artifact like "I have a Grafana dashboard at this URL."
