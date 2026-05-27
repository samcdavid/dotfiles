---
name: my-investigate
description: Investigate production or runtime issues by exploring logs, metrics, traces, and dashboards. Product-agnostic — works with any observability stack. Delegates evidence-gathering and hypothesis-testing to the `runtime-investigator` agent; keeps interactive context-gathering and decision-making in the main conversation.
disable-model-invocation: true
---

# Investigate Issue

Systematically investigate a production or runtime issue. The main window stays interactive (gather context, confirm hypotheses, decide on mitigations); evidence-gathering and hypothesis-testing run inside the `runtime-investigator` agent so logs/traces/metric data don't pollute the conversation.

## Step 1 — Gather initial context (interactive)

Collect from the user:

1. **Symptom** — errors, latency, data inconsistency, user reports, alert text
2. **When did it start?** — timestamp, "after deploy X", "this morning"
3. **Blast radius (suspected)** — all users, one tenant, one endpoint, one region. Verify later via the agent — do not trust the hint blindly.
4. **Observability tools** — Datadog, Grafana, CloudWatch, Honeycomb, app logs, custom dashboards. For each, capture how to access (MCP tool name, CLI, URL).
5. **Anything else** — relevant service/endpoint, suspect code paths, alert URLs, trace IDs, dashboard URLs, ticket URLs, error messages.

If the user provides an alert or error message, start there. If they provide a URL to a dashboard or trace, capture it for the agent to follow up on.

**Do NOT proceed without knowing how to access at least one observability source.** If no tools are accessible, ask. Investigating blind produces guesses, not evidence.

## Step 2 — Spawn the investigator

Invoke the `runtime-investigator` agent with the bundle:

```
- symptom
- started_at
- blast_radius_hint
- observability_tools: list of {name, access_method}
- relevant_service (or null)
- relevant_code_paths (or null)
- linked_artifacts: alert URLs, trace IDs, dashboards, tickets, error messages
```

The agent builds a timeline (via `ops-data-explorer` + `codebase-analyzer` in parallel), narrows the blast radius against actual data, traces the request path, tests hypotheses, and returns structured evidence + a ranked hypothesis list + targeted questions for you.

If the agent returns an `## Error` block (e.g. missing observability access), surface it and stop.

## Step 3 — Review findings with the user

Present the agent's output. Specifically draw attention to:

- **Blast radius (verified)** — especially if it disagrees with the user's hint
- **Ranked hypotheses** — present 1-3 with their evidence-for / evidence-against
- **Targeted questions** — ask each one; the user has context the agent can't retrieve

## Step 4 — Confirm root cause

Based on the ranked hypotheses + user answers:

1. Ask the user which hypothesis they want to confirm first.
2. If the agent's evidence is sufficient, confirm it together. If not, the agent's `Suggested Next Steps` section names what to investigate further — re-invoke the agent with the additional context if needed (max 2 follow-up rounds; if still inconclusive, escalate to a human investigator).
3. Once a root cause is confirmed:
   - **What broke?** specific code path, configuration, data issue, infrastructure failure
   - **Why did it break?** what changed — deploy, data, traffic, dependency
   - **Why wasn't it caught?** missing test, missing monitor, edge case not considered

## Step 5 — Mitigation and fix (user-driven)

Separate MITIGATION (stop the bleeding) from FIX (prevent recurrence). Both are the user's call — surface options, do not take them.

- **Mitigation options** — rollback, feature flag toggle, config change, scale-up. List the options the user can choose from. Do NOT execute any of them yourself.
- **Long-term fix** — code change, architecture improvement, process change. Surface the candidate; the user decides whether to implement now or schedule it.

If the user asks you to implement the long-term fix, switch to the appropriate skill (`my-implement`, `my-plan`) — do not implement from inside this investigation flow.

## Step 6 — Report

After confirmation, produce the investigation report:

```markdown
## Investigation: [Issue Title]
Date: [ISO timestamp]
Status: [active | mitigated | resolved]
Severity: [critical | high | medium | low]

### Timeline
- [Timestamp] — [Event grounded in evidence]
- [Timestamp] — [Event]

### Blast Radius
- Affected: [services, endpoints, users]
- Not affected: [healthy neighbors]

### Root Cause
[Clear explanation of what went wrong and why]

### Evidence
- [Source]: [specific data point]
- [Source]: [specific data point]

### Immediate Mitigation
[What was done or what's available — note who decided to apply each option]

### Long-term Fix
[Code change, architecture improvement, process change needed]

### Prevention
- [Monitor to add — so this alerts before users notice next time]
- [Test to add — so this gets caught in CI]
- [Process change — if applicable]

### Open Questions
[Anything still unclear]
```

## Step 7 — Verification

After a mitigation or fix is applied:
- Confirm the symptom is resolved (re-spawn the agent with the same observability scope to check the same metrics/logs that showed the problem)
- Verify no new issues introduced
- Watch for recurrence over a defined window

## Constraints

- **Read-only investigation.** The skill and the agent are both forbidden from applying mitigations, modifying configuration, restarting services, paging anyone, or editing code in the affected codebase. Surface options; the user decides.
- **Follow evidence, not intuition.** Every conclusion needs a data point.
- **Specific over vague.** Quote log lines, list trace IDs, name exact metric values. "The logs looked bad" is not evidence.
- **User-paced.** Ask before moving from investigation → mitigation → fix → verification. Each transition is a decision point.
