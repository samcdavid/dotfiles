## Constraints

- Do NOT start testing until the user confirms the app is running and ready
- Do NOT fabricate results — if you can't determine pass/fail from what the page shows, mark it BLOCKED and explain
- Do NOT rush through tests — capture enough frames for the GIF to be readable
- If a test FAILS, still continue with remaining tests — don't stop at the first failure
- If the browser becomes unresponsive or a tool fails after 2-3 attempts, stop and ask the user for guidance
- The GIF and results table should be independently useful — someone should understand the test from either one alone
- **Never skip tests because they're slow** (per the "Never skip tests" gotcha). Every test in the plan executes. A test is BLOCKED only when a genuine technical issue stops it (app down, browser unresponsive) — never "NOT EXECUTED — covered by automated tests." The user asked for manual E2E specifically; automated coverage isn't a substitute.
