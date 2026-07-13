## Step 7 — Verification

After a mitigation or fix is applied:

- **Production issues**: Re-spawn the agent with the same observability scope to confirm the symptom is gone and no new issues emerged.
- **CI issues**: Watch the retry pass on the actual pipeline. A re-run passing confirms nothing — only a stabilized test or root-cause fix does.
- Watch for recurrence over a defined window.
