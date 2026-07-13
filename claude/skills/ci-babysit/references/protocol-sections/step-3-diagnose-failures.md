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
