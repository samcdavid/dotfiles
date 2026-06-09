---
model: sonnet
name: my-investigate
description: Investigate production or runtime issues by exploring logs, metrics, traces, and dashboards. Product-agnostic — works with any observability stack. Delegates evidence-gathering and hypothesis-testing to the `runtime-investigator` agent; keeps interactive context-gathering and decision-making in the main conversation.
---

# Investigate Issue

Systematically investigate a production or runtime issue. The main window stays interactive (gather context, confirm hypotheses, decide on mitigations); evidence-gathering and hypothesis-testing run inside the `runtime-investigator` agent so logs/traces/metric data don't pollute the conversation.

## Step 1 — Gather initial context (minimal)

All you need to start is:

1. **Symptom** — errors, latency, data inconsistency, failing CI, alert text, error messages, trace IDs, dashboard URLs, ticket URLs

Everything else is either self-discoverable or the agent will surface it. Collect anything the user volunteers (timestamps, blast radius guesses, suspect code paths, observability tool names) but do not interrogate for items you can infer later.

**CI detection**: If the symptom mentions tests, CI, pipeline, build, spec, or flaky — mark `ci_issue: true`. The agent checks flaky tests and build logs before pursuing other angles.

**Do not ask for observability tool names.** The agent discovers available tools from MCP context. Ask only if the user references a specific artifact like "I have a Grafana dashboard at this URL."

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

## Step 3 — Review findings with the user

Present the agent's findings. Surface:

- **Blast radius (verified)** — call out any disagreement with the user's hint
- **Ranked hypotheses** — present the top 1–3 with their evidence-for / evidence-against
- **Targeted questions** — present all at once in a single batch; the user can answer in one reply. Do not ask one question per round-trip.

## Step 4 — Confirm root cause

Based on ranked hypotheses + any user answers:

1. **If there's a clear top hypothesis** (high confidence, evidence in its favor, no strong counter-evidence): present it as the likely root cause and ask the user to confirm or redirect. Do not ask the user to "pick" a hypothesis.
2. **If evidence is genuinely split**: surface the top two and ask which to pursue first.
3. Re-invoke the agent with additional context if more investigation is needed. Escalate to a human investigator when the investigation is going in circles — not after a fixed number of rounds.

Once root cause is confirmed:
- **What broke?** specific code path, configuration, data issue, infrastructure failure
- **Why did it break?** what changed — deploy, data, traffic, dependency
- **Why wasn't it caught?** missing test, missing monitor, edge case not considered

## Step 5 — Mitigation and fix (user-driven)

Separate MITIGATION (stop the bleeding) from FIX (prevent recurrence). Both are the user's call — surface options, do not take them.

- **Mitigation options** — rollback, feature flag toggle, config change, scale-up, re-run CI job, skip flaky test. List options the user can choose from. Do NOT execute any of them yourself.
- **Long-term fix** — code change, architecture improvement, process change, flaky test stabilization. Surface the candidate; the user decides whether to implement now or schedule it.

If the user asks you to implement the long-term fix, switch to the appropriate skill (`my-implement`, `my-plan`) — do not implement from inside this investigation flow.

## Step 6 — Report

Produce a tiered report based on investigation complexity.

**Short form** — for simple or already-resolved issues (known flaky test, clear single-commit regression, self-healed incident):

```markdown
## Investigation: [Issue Title]
Date: [ISO timestamp] | Status: [mitigated | resolved] | Severity: [critical | high | medium | low]

**Root Cause**: [One clear sentence]
**Evidence**: [Key data point(s)]
**Fix applied / recommended**: [What was done or should be done]
**Prevention**: [One targeted follow-up action]
```

**Full form** — for complex, multi-hypothesis, or still-active issues:

```markdown
## Investigation: [Issue Title]
Date: [ISO timestamp]
Status: [active | mitigated | resolved]
Severity: [critical | high | medium | low]

### Timeline
- [Timestamp] — [Event grounded in evidence]

### Blast Radius
- Affected: [services, endpoints, users]
- Not affected: [healthy neighbors]

### Root Cause
[Clear explanation of what went wrong and why]

### Evidence
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

- **Production issues**: Re-spawn the agent with the same observability scope to confirm the symptom is gone and no new issues emerged.
- **CI issues**: Watch the retry pass on the actual pipeline. A re-run passing confirms nothing — only a stabilized test or root-cause fix does.
- Watch for recurrence over a defined window.

## Constraints

- **Read-only investigation.** The skill and the agent are both forbidden from applying mitigations, modifying configuration, restarting services, paging anyone, or editing code in the affected codebase. Surface options; the user decides.
- **Follow evidence, not intuition.** Every conclusion needs a data point.
- **Specific over vague.** Quote log lines, list trace IDs, name exact metric values. "The logs looked bad" is not evidence.
- **User-paced.** Ask before moving from investigation → mitigation → fix → verification. Each transition is a decision point.
