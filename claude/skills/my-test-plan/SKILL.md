---
name: my-test-plan
description: Analyze a ticket and PR to produce a structured manual E2E test plan. Reads the ticket requirements, understands the bug or feature, reviews the code changes, and designs targeted test scenarios with expected outcomes.
disable-model-invocation: true
---

# Manual Test Plan

Produce a structured E2E test plan for a ticket/PR. The plan defines WHAT to test, not how to click through it — execution is handled by `my-test-exec`.

## Getting Started

Determine context from `$ARGUMENTS`:
- PR number or URL → fetch the PR and linked ticket
- Linear ticket ID or URL → fetch the ticket and find associated PRs
- If empty, ask the user what to test

## Step 1 — Gather Context

Collect all relevant information in parallel:

**From the ticket (Linear):**
- Problem statement / bug description
- Acceptance criteria if present
- Reproduction steps if it's a bug
- Any linked issues or dependencies

**From the PR:**
```bash
gh pr view <number>
gh pr diff <number>
```

**From the codebase:**
- Spawn a **codebase-analyzer** agent to understand the changed code — what it does, what it affects, what could break

Read the ticket and PR description carefully. The test plan should verify the STATED PROBLEM is fixed, not just that the code compiles.

## Step 2 — Design Test Scenarios

Create test scenarios that cover:

1. **Primary fix/feature** — Does the stated problem get resolved? (most important)
2. **Edge cases from the ticket** — Any scenarios mentioned in the bug report or acceptance criteria
3. **Regression guard** — Related functionality that should NOT break (e.g., if a move operation was fixed, verify that edit operations still work)
4. **No-op / boundary cases** — What happens at the edges? (empty input, already-in-desired-state, etc.)

Keep the number of tests focused — 3-6 is typical. Don't pad with low-value tests.

## Step 3 — Present the Plan

Format as a numbered table:

```markdown
## Manual Test Plan — [TICKET-ID]

**Context:** [1-2 sentences on what the change does and what the tests verify]

**Prerequisites:**
- [What needs to be running, seeded, or configured before testing]

| # | Test | Expected Outcome |
|---|------|-------------------|
| 1 | **[Descriptive name]** — [What to do] | [What should happen] |
| 2 | **[Descriptive name]** — [What to do] | [What should happen] |
| 3 | **[Descriptive name]** — [What to do] | [What should happen] |
```

## Constraints

- Do NOT execute the tests — only define them
- Do NOT include implementation-level details (CSS selectors, API calls) — keep tests at the user-visible behavior level
- Every test must have a CLEAR expected outcome — "works correctly" is not an outcome; "responds with a single message and does not reindex siblings" is
- Tests should be ordered: happy path first, then edge cases, then regressions
- If the ticket describes a specific "weird behavior" or symptom, at least one test must directly verify that symptom is gone
