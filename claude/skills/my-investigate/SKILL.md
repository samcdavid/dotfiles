---
name: my-investigate
description: Investigate production or runtime issues by exploring logs, metrics, traces, and dashboards. Product-agnostic — works with any observability stack. Follows the evidence to root cause.
disable-model-invocation: true
---

# Investigate Issue

Systematically investigate a production or runtime issue. Follow the evidence — don't guess.

## Getting Started

Gather initial context from the user:
1. **What's the symptom?** (errors, latency, data inconsistency, user reports, alert firing)
2. **When did it start?** (timestamp, "after deploy X", "this morning")
3. **What's the blast radius?** (all users, specific tenant, one endpoint, one region)
4. **What observability tools are available?** (Datadog, Grafana, CloudWatch, Honeycomb, app logs, etc.)
5. **How do we access them?** (MCP tools, CLI, URLs, API keys)

If the user provides an alert or error message, start there. If they provide a URL to a dashboard or trace, access it.

Do NOT proceed without knowing how to access at least one data source. If unclear, ask.

## Step 1 — Establish Timeline

Build a timeline of events. Spawn parallel exploration:
- **ops-data-explorer**: Query logs/metrics for the affected time range
- **codebase-analyzer**: Read the relevant code paths (if the affected service/endpoint is known)

Key questions for the timeline:
- When exactly did the issue start? (first error, first metric deviation)
- Was there a deploy, config change, or dependency update around that time?
- Is the issue ongoing, intermittent, or resolved?
- Is there a pattern? (time of day, traffic volume, specific inputs)

## Step 2 — Narrow the Blast Radius

Determine what's affected and what ISN'T:
- Which endpoints/services/jobs are impacted?
- Which are healthy? (healthy neighbors help isolate the cause)
- Is it correlated with specific users, tenants, regions, or input types?
- Are downstream services affected? (cascading failure vs. isolated issue)

## Step 3 — Follow the Request Path

Trace a failing request end-to-end:

1. **Entry point**: Load balancer, API gateway, or queue consumer — is the request arriving?
2. **Application layer**: Is the code executing? Where does it fail? (check logs for stack traces, error messages)
3. **Data layer**: Database queries succeeding? Correct data returned? Connection pool healthy?
4. **External dependencies**: Third-party APIs responding? Timeouts? Changed behavior?
5. **Infrastructure**: Container health, memory, CPU, disk, network

At each layer, gather SPECIFIC evidence:
- Exact error messages and stack traces
- Trace IDs that can be followed across services
- Metric values with timestamps
- Log lines with request identifiers

## Step 4 — Hypothesize and Test

Based on evidence, form hypotheses:

```
Hypothesis: [What you think is happening]
Evidence For: [What supports this]
Evidence Against: [What contradicts this]
Test: [How to confirm or rule out — a query, a log search, a code read]
```

Test the MOST LIKELY hypothesis first. If it doesn't hold, move to the next. Don't get attached to a theory — follow the data.

## Step 5 — Root Cause Analysis

Once the root cause is identified:

1. **What broke?** (specific code path, configuration, data issue, infrastructure failure)
2. **Why did it break?** (what changed — deploy, data, traffic, dependency)
3. **Why wasn't it caught?** (missing test, missing monitor, edge case not considered)
4. **What's the fix?** (immediate mitigation AND long-term correction)

## Step 6 — Report

```markdown
## Investigation: [Issue Title]
Date: [ISO timestamp]
Status: [active | mitigated | resolved]
Severity: [critical | high | medium | low]

### Timeline
- [Timestamp] — [Event]
- [Timestamp] — [Event]
...

### Blast Radius
- Affected: [services, endpoints, users]
- Not affected: [healthy neighbors]

### Root Cause
[Clear explanation of what went wrong and why]

### Evidence
- [Source]: [specific data point]
- [Source]: [specific data point]

### Immediate Mitigation
[What to do right now to stop the bleeding — rollback, feature flag, config change]

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

After a fix is applied:
- Confirm the symptom is resolved (check the same metrics/logs that showed the problem)
- Verify no new issues introduced
- Watch for recurrence over a defined window

## Guidelines

- Follow the EVIDENCE, not intuition — every conclusion needs supporting data
- Start broad, narrow progressively — don't tunnel-vision on the first theory
- Collect specific data points (timestamps, trace IDs, error messages) — "the logs looked bad" is not evidence
- If you can't access a data source, tell the user what you need and why
- Separate MITIGATION (stop the bleeding now) from FIX (prevent recurrence)
- Be platform-agnostic in analysis — use whatever tools are available
- If the issue is actively impacting users, prioritize mitigation over perfect root cause analysis
