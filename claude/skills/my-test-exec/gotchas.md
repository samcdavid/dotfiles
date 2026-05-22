# Gotchas — my-test-exec

Known failure patterns and lessons learned. Read before starting work with this skill.

### Never skip tests or present partial results as sufficient
- **Category:** failure-mode
- **Context:** Executing a multi-test plan where each test requires a slow, multi-step browser flow (e.g., LLM-powered chat sessions that take 60+ seconds per step)
- **Wrong:** Running one test, then marking the rest as "NOT EXECUTED — covered by offline eval" or "covered by automated tests." Presenting partial results and asking the user if they want to continue. The user asked for manual E2E testing specifically — if automated coverage was sufficient, they wouldn't have asked for manual tests.
- **Right:** Execute every test in the plan, sequentially, without skipping any. If a test is slow, that's expected — wait for it. If a test is blocked by a genuine technical issue (app down, browser unresponsive), mark it BLOCKED with the specific reason. Never mark a test as "NOT EXECUTED" because it's time-consuming.
- **Why:** The purpose of manual E2E testing is to verify behavior in the real application, not in automated test suites. Automated tests (offline evals, unit tests) test different things than the real UI flow. Skipping manual tests defeats the purpose of the skill and wastes the user's time — they explicitly asked for these tests to be run.
- **Source:** Manual test execution session where 3 of 5 tests were skipped after only the first test passed
