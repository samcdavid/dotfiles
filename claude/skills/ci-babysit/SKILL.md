---
name: ci-babysit
description: Monitor a PR's CircleCI pipeline until all jobs pass. Polls for status, diagnoses failures, applies fixes, pushes, and re-monitors. Does not stop until the entire pipeline is green or you intervene.
disable-model-invocation: true
---

# CI Babysit

Monitor a PR's CircleCI pipeline from start to finish. When something fails, diagnose it, fix it, push the fix, and keep watching. Do not stop until every job in the pipeline is green.

## Getting Started

Determine what to monitor:
- If `$ARGUMENTS` contains a PR number or URL → monitor that PR's pipeline
- If `$ARGUMENTS` contains a CircleCI pipeline/workflow URL → monitor that directly
- If `$ARGUMENTS` is empty → detect from the current branch:

```bash
git branch --show-current
git remote get-url origin
```

Then use `gh pr view` to find the PR for the current branch. If no PR exists, ask whether to monitor the branch pipeline directly.

## Step 1 — Identify the Pipeline

Establish the CircleCI project and branch context:

1. Get the git remote URL and current branch name
2. Use `mcp__circleci-mcp-server__get_latest_pipeline_status` with project detection (workspaceRoot + gitRemoteURL + branch) to get the current pipeline state
3. Record the pipeline number, workflow IDs, and initial job statuses

If no pipeline is running yet (e.g. just pushed), wait and re-check. The pipeline may take a moment to be created.

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
- Wait 60 seconds between checks
- Give a brief status update every 3 checks (~3 minutes): which jobs are running, how long they've been going
- If a job has been running for an unusually long time (>30 minutes without progress), flag it but keep waiting

### Approval Gates

If a job is `on_hold` (manual approval required):
- Notify immediately: "Job `[name]` is waiting for manual approval in workflow `[workflow]`"
- Do NOT attempt to approve — this requires human action
- Continue monitoring other jobs while waiting
- Re-check the held job on each loop iteration

## Step 3 — Diagnose Failures

When a job fails:

### Gather Failure Context

Run in parallel:
1. `mcp__circleci-mcp-server__get_build_failure_logs` — get the failure logs for the branch
2. `mcp__circleci-mcp-server__get_job_test_results` with `filterByTestsResult: 'failure'` — get failed test details

### Classify the Failure

| Category | Signals | Action |
|----------|---------|--------|
| **Test failure** | Failed test names, assertion errors, test output | Fix the failing test or the code it tests |
| **Compilation/build error** | Syntax errors, type errors, missing imports, module not found | Fix the build error |
| **Lint/format failure** | Linter output, formatter diff, style violations | Run the linter/formatter locally and fix |
| **Dependency issue** | Missing package, version conflict, lockfile mismatch | Fix dependency resolution |
| **Infrastructure/flaky** | Timeout, network error, Docker pull failure, OOM, no matching node | Rerun the workflow — not a code issue |
| **Migration failure** | Database errors, migration conflicts | Fix the migration |
| **Unknown** | Unclear logs, no obvious pattern | Present the logs to the user and ask for guidance |

### Flaky Test Detection

Before fixing a test failure, check if it's a known flaky test:
- Use `mcp__circleci-mcp-server__find_flaky_tests` to check the project's flaky test list
- If the failing test is on the flaky list, rerun the workflow instead of investigating the test
- Note the flaky test in the status update so it can be addressed separately

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

## Step 5 — Status Reporting

### During Monitoring
Brief updates at natural points:
```
[HH:MM] Pipeline #N — 5/8 jobs passed, 2 running (test_unit: 4m, test_integration: 7m), 1 queued
```

### On Failure Detection
```
[HH:MM] FAILED: job `test_unit` in workflow `build_and_test`
Failure: 2 tests failed in test/accounts/user_test.exs
- test_create_user_with_invalid_email (line 42): expected {:error, changeset}, got {:ok, user}
- test_update_user_permissions (line 87): ** (MatchError) no match of right hand side value
Diagnosing...
```

### On Fix Applied
```
[HH:MM] Fix pushed (abc1234): Fix email validation in User changeset
New pipeline triggered — resuming monitoring...
```

### On Completion
```
## CI Complete — All Green

Pipeline #N — all 8 jobs passed
Duration: 23 minutes (wall clock), 47 minutes (total compute)
Fixes applied: 2 commits
- abc1234: Fix email validation in User changeset
- def5678: Fix missing preload in permissions test

Flaky reruns: 1 (test_integration — known flaky: test_webhook_delivery)
Approval gates: 1 (deploy_staging — approved by @sam at 14:32)
```

## Constraints

- **Always rerun from failure, not from start** — when rerunning a workflow (flaky tests, infra failures), always use `fromFailed: true`. Rerunning from start wastes time re-running jobs that already passed. Only rerun from start if explicitly asked or if the failure suggests earlier jobs produced bad artifacts.
- **Never stop monitoring until every job is green** — the whole point is that you babysit it to completion. Running jobs mean keep waiting. Failed jobs mean fix and retry. The only exits are: all green, user interrupts, or fix limit reached.
- **Never modify CI configuration** — `.circleci/config.yml` and pipeline config are off-limits. If the config is the problem, tell the user.
- **Never approve gates** — approval jobs require human judgment. Notify and wait.
- **Never force-push** — always add new commits on top.
- **Never skip hooks** — if a pre-commit hook fails on your fix, fix the hook issue too.
- **Minimal fixes only** — fix exactly what's failing. Don't refactor, don't improve, don't clean up. The goal is green CI, not better code.
- **Ask when stuck** — if you can't determine why something failed or how to fix it, present the failure to the user rather than guessing.
