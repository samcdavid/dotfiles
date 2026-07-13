## Step 5 — TDD Implement

Strict red/green/validate, mirrored from `/my-implement`. (As a single-pass fast path, you run the cycle inline here rather than dispatching to an executor subagent.)

### RED — failing test first

1. Write the test
2. Run it — must FAIL for the right reason (missing behavior, not a syntax error)
3. If it passes immediately, the test is wrong — rewrite

**Hard rule:** do not proceed to GREEN until the test fails for the right reason.

### GREEN — minimum code to pass

1. Write the smallest production code change that satisfies the test
2. Run the test — must PASS
3. Run the broader test file/module — nothing unrelated should break

### VALIDATE

Confirm the change meets its requirements — that the behavior actually matches what was asked, not just that tests are green. Run the success criteria and the relevant suite as evidence; verify the tests genuinely encode the requirement. Fold in any obvious, behavior-preserving cleanup here (don't gold-plate); tests must still pass after.

### Loop Detection

If the SAME check fails 3 times across attempts, **STOP**. Present:

- What I'm trying to accomplish
- What keeps failing (with error output)
- What I've tried
- My best theory on root cause
- Suggested next step (often: escalate to the full pipeline)

Do NOT keep retrying. Escalation is efficiency, not failure.
