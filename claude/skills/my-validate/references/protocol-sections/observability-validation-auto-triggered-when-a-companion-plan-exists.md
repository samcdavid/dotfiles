## Observability Validation (Auto-triggered when a companion plan exists)

When a companion observability plan is detected, validate that the instrumentation described in it was actually implemented.

### Step 1 — Parse the Observability Plan

Read the observability plan file. Extract:
- Every **metric** (name, type, source file/function)
- Every **span** (name, location)
- Every **log statement** (location, expected fields)

### Step 2 — Verify Implementation in Code

For each instrumentation point, read the source file(s) listed and verify:

1. **Metrics**: Is the counter/histogram/gauge emitted at the described location? Do the tag/label names match?
2. **Spans**: Is `tracer.trace(...)` (or equivalent) wrapping the described block? Are the specified attributes attached?
3. **Logs**: Is the log statement present with the expected fields/format?

Record each as: IMPLEMENTED, MISSING, or PARTIAL (present but deviates from plan).

### Step 3 — Self-Repair

For anything MISSING or PARTIAL:
1. Diagnose what's actually in the code vs. what the plan specifies
2. Implement the missing instrumentation or correct the deviation
3. Re-verify

If a fix can't be made confidently (e.g. platform-specific setup needed, unclear ownership), escalate to the user.

### Step 4 — Append to Validation Report

Add an **Observability** section to the validation report:

```markdown
### Observability Validation

#### Metrics
- `metric.name` — IMPLEMENTED at `file:line` / MISSING / PARTIAL (deviation)

#### Spans
- `span.name` — IMPLEMENTED at `file:line` / MISSING / PARTIAL

#### Logs
- `log_statement` at `file:line` — IMPLEMENTED / MISSING / PARTIAL

#### Self-Repairs Made
- [What was missing → what was added → verification result]

#### Issues Requiring Attention
- [Issue, reason it couldn't be auto-fixed]
```

Update the observability plan's `status` to `validated` or `needs-attention`.

---
