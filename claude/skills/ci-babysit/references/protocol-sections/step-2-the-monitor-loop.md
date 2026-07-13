## Step 2 — The Monitor Loop

```
LOOP (until all jobs pass or user interrupts):
  1. CHECK   — Get current pipeline/workflow status
  2. ASSESS  — Categorize each job: running, queued, success, failed, on_hold
  3. DECIDE  — Based on assessment:
     - All jobs passed     → EXIT with success summary
     - Jobs still running  → WAIT and re-check
     - Job failed          → DIAGNOSE and FIX
     - Job on hold         → NOTIFY user (manual approval gates)
  4. REPORT  — Brief status update
```

### Check Status

Use `mcp__circleci-mcp-server__get_latest_pipeline_status` to get the current state. Track:
- Pipeline status (running, success, failed)
- Each workflow's status
- Each job within each workflow (name, status, duration)

### Wait Strategy

When jobs are still running:
- Wait 90 seconds between checks — never exceed 2 minutes between checks
- Give a brief status update every 2 checks (~3 minutes): which jobs are running, how long they've been going
- If a job has been running for an unusually long time (>30 minutes without progress), flag it but keep waiting

### Approval Gates

If a job is `on_hold` (manual approval required):
- Notify immediately: "Job `[name]` is waiting for manual approval in workflow `[workflow]`"
- Do NOT attempt to approve — this requires human action
- Continue monitoring other jobs while waiting
- Re-check the held job on each loop iteration
