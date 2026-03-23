---
name: my-test-exec
description: Execute a manual E2E test plan using Claude in Chrome. Walks through each test scenario in the browser, records a GIF of the session, and formats a results table. Optionally posts results and GIF to a GitHub PR.
disable-model-invocation: true
---

# Execute Manual Test Plan

Execute a test plan against a running application using Chrome browser automation. Record a GIF of the session and produce a structured results table.

## Getting Started

Determine context from `$ARGUMENTS`:
- If a test plan was just produced in this conversation, use it
- If `$ARGUMENTS` contains a PR number, use it for GIF storage and posting
- If no test plan exists in context, ask the user to provide one or run `my-test-plan` first
- If the PR number is not known, ask for it

Confirm with the user:
1. The app is running locally and accessible in Chrome
2. Any required test data or state is set up (per the plan's prerequisites)

## Step 1 — Prepare

1. Get the PR number (from arguments or ask)
2. Create the output directory:
```bash
mkdir -p ~/Downloads/PR-<number>
```
3. Call `mcp__claude-in-chrome__tabs_context_mcp` to see current browser state
4. Identify or create the tab where the app is running

## Step 2 — Start GIF Recording

Start the GIF recorder before executing tests:
- Use `mcp__claude-in-chrome__gif_creator` to begin recording
- Name the file descriptively: `~/Downloads/PR-<number>/<ticket-id>-<short-description>.gif`
  (e.g., `~/Downloads/PR-24468/cnvs-421-move-questions-test.gif`)

Capture extra frames before and after each action for smooth playback.

## Step 3 — Execute Each Test

For each test in the plan, in order:

1. **Navigate** to the starting point for the test
2. **Perform** the described action using browser tools (click, type, navigate)
3. **Observe** the result — read the page to determine what actually happened
4. **Record** the result:
   - **PASS** — observed behavior matches expected outcome
   - **FAIL** — observed behavior differs from expected outcome (capture what actually happened)
   - **BLOCKED** — could not execute the test (explain why)
5. **Capture extra frames** to show the result state before moving to the next test

Between tests, pause briefly to let the GIF show clear transitions.

## Step 4 — Stop Recording and Save

Stop the GIF recording. The file should be saved at:
`~/Downloads/PR-<number>/<ticket-id>-<short-description>.gif`

## Step 5 — Format Results

Produce a results table:

```markdown
## Manual E2E Test Results — [TICKET-ID]

Tested [brief description of what was tested] against [environment/dataset context].

| # | Test | Result | Notes |
|---|------|--------|-------|
| 1 | **[Test name]** | PASS/FAIL | [What actually happened — be specific] |
| 2 | **[Test name]** | PASS/FAIL | [Notes] |

**[Summary sentence]** — e.g., "The core bug is fixed — in all N tests, [observed behavior]. The symptom described in the issue is no longer reproducible."
```

## Step 6 — Post to PR (if requested)

If the user wants results posted to the PR:

1. Post the results table as an issue comment:
```bash
gh api repos/{owner}/{repo}/issues/{number}/comments -f body="$(cat <<'EOF'
[results table from Step 5]
EOF
)"
```

2. Tell the user the GIF location (`~/Downloads/PR-<number>/...`) so they can manually upload it to the PR comment (GitHub doesn't support CLI image uploads to comments).

## Constraints

- Do NOT start testing until the user confirms the app is running and ready
- Do NOT fabricate results — if you can't determine pass/fail from what the page shows, mark it BLOCKED and explain
- Do NOT rush through tests — capture enough frames for the GIF to be readable
- If a test FAILS, still continue with remaining tests — don't stop at the first failure
- If the browser becomes unresponsive or a tool fails after 2-3 attempts, stop and ask the user for guidance
- The GIF and results table should be independently useful — someone should understand the test from either one alone
