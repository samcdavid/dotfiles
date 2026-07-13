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
