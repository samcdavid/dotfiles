## Step 4 — Fix and Push

### For Code Fixes

1. **Read the failing code and tests** — understand what's broken before changing anything
2. **Make the minimal fix** — fix only what's failing, nothing else
3. **Run the check locally first if possible** — try to reproduce and verify the fix before pushing:
   - Tests: run the specific failing test locally
   - Lint: run the linter locally
   - Build: compile locally
4. **Commit the fix** using a clear message:
   ```
   Fix CI: [brief description of what was fixed]
   ```
5. **Push the fix**:
   ```bash
   git push
   ```
6. **Return to Step 2** — the push will trigger a new pipeline, resume monitoring. Note: pushing triggers a full new pipeline, which is unavoidable for code fixes. For non-code retries (flaky, infra), always rerun from failure instead.

### For Infrastructure/Flaky Failures

1. Use `mcp__circleci-mcp-server__rerun_workflow` with `fromFailed: true` to rerun from the failed job — always prefer rerunning from failure rather than from the start to avoid re-running jobs that already passed
2. **Return to Step 2** — resume monitoring the rerun

### Fix Limits

- **Max 3 fix attempts per job** — if the same job fails 3 times after fixes, stop and escalate to the user: "Job `[name]` has failed 3 times. Here's what I've tried and what the current failure looks like."
- **Max 2 flaky reruns per job** — if a job fails after 2 reruns with no code changes, it's probably not flaky. Investigate properly.
- **Never force-push** — always create new commits for fixes
- **Never modify CI config** — if the pipeline config itself seems wrong, flag it for the user
