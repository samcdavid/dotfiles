---
name: my-observe
description: Design observability and monitoring for code changes. Identifies metrics, traces, and spans to capture, and recommends pragmatic monitors/alerts that clearly indicate real problems worth waking someone up for. Product-agnostic.
disable-model-invocation: true
---

# Observability & Monitoring Design

Identify what to monitor and how to alert for code changes — pragmatically. Monitors should catch real problems, not generate noise.

## Getting Started

Determine scope:
- If `$ARGUMENTS` references a plan, PR, or file path → analyze those specific changes
- If empty → ask the user what changes or system to design monitoring for

Establish the observability stack:
- Ask what platforms are available (Datadog, Grafana, Prometheus, CloudWatch, Honeycomb, New Relic, etc.)
- Ask about alerting channels (PagerDuty, OpsGenie, Slack, etc.)
- If the user isn't sure, keep recommendations platform-agnostic and let them adapt

## Step 1 — Understand the Change

Read the code changes fully. Spawn parallel agents:
- **codebase-analyzer**: Understand the implementation, data flow, and failure modes
- **docs-researcher**: Look up observability best practices for the specific frameworks/libraries in use

Identify:
- What are the CRITICAL operations? (must succeed for the feature to work)
- What are the EXPECTED failure modes? (network timeouts, invalid input, rate limits)
- What are the UNEXPECTED failure modes? (logic bugs, data corruption, silent failures)
- What downstream systems are affected?

## Step 2 — Metrics Design

For each critical operation, identify metrics to capture:

### Request/Operation Metrics (RED method)
- **Rate**: requests per second, operations per minute
- **Errors**: error count and error rate (percentage)
- **Duration**: latency percentiles (p50, p95, p99)

### Resource Metrics (USE method)
- **Utilization**: CPU, memory, disk, connection pools
- **Saturation**: queue depth, thread pool exhaustion, backpressure
- **Errors**: resource-level failures (connection refused, OOM)

### Business Metrics
- **Success rate for valid input**: The feature should work for good input — if it doesn't, something is broken
- **Throughput**: Are operations completing at the expected volume?
- **Data quality**: Are outputs valid? (schema violations, empty responses, truncated data)

Specify each metric as:
```
Metric: [name]
Type: counter | gauge | histogram | summary
Labels/Tags: [dimensions for filtering]
Source: [where to instrument — file:function or middleware/framework hook]
```

## Step 3 — Tracing & Spans

Identify key spans to instrument:
- Entry point span (HTTP request, job execution, event handler)
- External call spans (database, API, cache, queue)
- Business logic spans (critical decision points, branching logic)

For each span:
```
Span: [name]
Location: [file:function]
Attributes: [key contextual data to attach — IDs, types, sizes]
Events: [notable occurrences within the span — retries, fallbacks, cache misses]
```

Focus on spans that help answer: "Where did time go?" and "Where did it fail?"

## Step 4 — Monitor & Alert Design

Design monitors that are PRAGMATIC — each alert should clearly indicate a real problem worth investigating.

### Alert Philosophy

**ALERT-WORTHY** (something is broken and needs human attention):
- Feature success rate drops below threshold for valid input
- Error rate spikes above baseline (sustained, not transient)
- Latency p99 exceeds SLA or user-facing timeout
- Queue depth growing unbounded (processing stalled)
- Data consistency violations (expected invariants broken)
- Zero throughput when traffic is expected (silent failure)

**NOT ALERT-WORTHY** (operational but not broken):
- Traffic increase requiring autoscaling (unless clearly anomalous/DDoS)
- Individual request failures within normal error budget
- Transient spikes that self-resolve within minutes
- Resource utilization below saturation threshold
- Expected maintenance windows or deploy-time blips

### For Each Monitor

```
Monitor: [descriptive name]
Signal: [metric or log query]
Condition: [threshold, window, evaluation period]
Severity: critical | warning | info
Why This Matters: [what user-facing impact this indicates]
Triage Steps:
  1. [First thing to check]
  2. [Second thing to check]
  3. [Escalation path if unresolved]
Context to Include in Alert:
  - [Key data to attach — trace IDs, affected endpoints, user counts]
```

### Noise Prevention

Every monitor must pass these checks:
- [ ] Would this alert fire during a normal deploy? If yes, add deploy-awareness or window exclusion.
- [ ] Would this alert fire during expected traffic patterns? If yes, tighten the condition.
- [ ] Can the on-call person ACT on this alert? If not, it's informational, not an alert.
- [ ] Does the alert include enough context to START investigating without opening 3 dashboards first?

## Step 5 — Dashboard Recommendations

Suggest dashboard panels that give at-a-glance health:
- Service overview (rate, errors, duration)
- Feature-specific success/failure breakdown
- Dependency health (database latency, external API availability)
- Queue/job health (depth, processing rate, failure rate)

Keep it to ONE dashboard with the critical signals — not a sprawling collection.

## Step 6 — Output

```markdown
## Observability Plan: [Feature/Change Name]

### Metrics to Instrument
[Table or list of metrics with type, labels, source]

### Traces & Spans
[Key spans with locations and attributes]

### Monitors & Alerts
[Each monitor with condition, severity, triage steps]

### Dashboard
[Recommended panels]

### Implementation Notes
[Platform-agnostic instrumentation guidance — where to add code, what libraries to use]
```

## Guidelines

- Every alert must have TRIAGE STEPS — an alert without guidance is just noise
- Prefer RATE-based alerts over COUNT-based (rate normalizes for traffic changes)
- Use SUSTAINED conditions (e.g., "above threshold for 5 minutes") not instantaneous spikes
- Include context in alerts — trace IDs, affected resource identifiers, links to relevant dashboards
- Start with fewer, high-signal monitors. More can be added after baseline is established.
- When unsure about the platform, write the logic in plain language and let the user translate to their tool's query syntax
