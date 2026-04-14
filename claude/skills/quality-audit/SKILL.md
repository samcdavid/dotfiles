---
name: quality-audit
description: Deep test quality and QA audit of code changes or a codebase area. Evaluates test coverage, test fidelity, assertion quality, test architecture, flakiness risk, and whether the test suite actually catches the bugs it claims to prevent. Goes deeper than test checks in a code review.
disable-model-invocation: true
---

# Quality Audit

Perform a dedicated quality and test fidelity audit. This goes deeper than the test checks in a code review — it's a focused pass evaluating whether the test suite is trustworthy, whether coverage is meaningful, and whether the testing strategy matches the risk profile of the code.

## Getting Started

Determine scope:
- If `$ARGUMENTS` contains a PR number → audit tests for that PR's changes
- If `$ARGUMENTS` contains file paths → audit test coverage for those files
- If `$ARGUMENTS` names a feature or area → discover and audit all related tests
- If empty → ask the user what to audit

## Step 1 — Map the Testing Landscape

Spawn parallel agents:
- **codebase-locator**: Find all test files related to the audit scope, plus the production code they cover
- **codebase-analyzer**: Trace the code paths in the changed/target production code — branches, error paths, external calls, state transitions
- **codebase-pattern-finder**: Identify the project's testing conventions — test organization, factory patterns, helper usage, mock strategy, assertion style

Identify:
- All production code paths that should be tested (happy path, error paths, edge cases, boundary conditions)
- All existing tests that exercise the target code (direct and indirect)
- The testing stack (framework, assertion library, factory/fixture approach, mock/stub tools)
- Test organization conventions (file placement, describe/context structure, naming)

## Step 2 — Test Coverage Analysis

### Structural Coverage
For every function and branch in the target production code:
- Is there a test that exercises this path?
- Is the test direct (unit test for this function) or indirect (integration test that happens to pass through)?
- Are both sides of conditionals tested? (if/else, case branches, guard clauses, pattern match arms)
- Are error/failure paths tested, not just happy paths?

### Meaningful Coverage
Coverage lines hit ≠ coverage that catches bugs. For every test:
- Does the assertion actually verify the behavior, or just that the code didn't crash?
- Could the implementation be replaced with a completely wrong one and the test still pass? (vacuous test)
- Are assertions checking specific values, or just shape/type? (`assert result == %{id: 1, name: "Sam"}` vs. `assert is_map(result)`)
- Are error assertions checking the specific error, or just that an error occurred? (`assert {:error, :not_found} = result` vs. `assert {:error, _} = result`)

### Coverage Gaps
Identify untested or under-tested areas:
- Functions with no direct tests (only exercised through integration tests)
- Branches with no test (the else clause nobody wrote a test for)
- Error paths with no test (what happens when the external API returns 500?)
- Boundary conditions with no test (empty list, nil, zero, max int, unicode, very long strings)
- Concurrent/race condition scenarios with no test

## Step 3 — Test Fidelity

### Do Tests Test What They Claim?
For every test, read the test name/description and compare to what the test actually does:
- Does `"creates a user with valid params"` actually verify the user was persisted with the correct attributes?
- Does `"returns error for invalid input"` actually pass invalid input and check the specific error?
- Are there tests that describe one behavior but assert another?
- Are there tests that pass due to setup side effects rather than the action under test?

### Test Isolation
- Do tests depend on execution order? (shared state between tests)
- Do tests depend on database state from other tests? (missing cleanup, shared fixtures)
- Could a test pass in isolation but fail when run with the full suite, or vice versa?
- Are there global mocks or stubs that bleed between tests?

### Flakiness Risk
Identify tests likely to flake:
- Time-dependent tests (assertions on timestamps, sleep-based waits, timezone sensitivity)
- Tests that depend on external services without mocking or sandboxing
- Tests with race conditions (async operations asserted synchronously)
- Tests with randomized data where the random value could hit an edge case
- Tests that assert on ordering without explicit ORDER BY
- Tests that depend on system resources (file system, network, available ports)

### Mock/Stub Fidelity
- Do mocks match the actual interface they replace? (same arity, same return types)
- Are mocked behaviors realistic? (mocking a function to always succeed when it can fail in production)
- Are there stale mocks for interfaces that have changed? (mock returns old shape, production returns new shape)
- Is the mock boundary appropriate? (mocking too close to the code under test hides real bugs; mocking too far away makes tests slow and fragile)

## Step 4 — Test Architecture

### Test Pyramid Assessment
- Is the balance right? (many unit tests, fewer integration tests, fewest E2E tests)
- Are there integration tests that should be unit tests? (testing branching logic through the full stack)
- Are there unit tests that should be integration tests? (mocking so much that the test doesn't verify real behavior)
- Are E2E tests reserved for critical user journeys, not individual features?

### Test Placement
- Are tests co-located with the code they test? (following project conventions)
- Are detailed logic tests at the unit level, close to the function?
- Are integration tests verifying wiring only — one happy-path test to confirm pieces connect?
- If a new module was added, does it have its own unit tests? (not only tested through a parent module's integration test)

### Factory/Fixture Quality
- Do factories produce valid, realistic data? (not `name: "test"`, `email: "a@b.c"`)
- Are factories composable? (traits/overrides for different scenarios)
- Are there factory anti-patterns? (factories that trigger side effects, factories that are stale relative to schema)
- Is factory usage consistent with project conventions?

### Test Readability
- Can someone understand what behavior is being tested without reading the implementation?
- Are test names descriptive of the behavior, not the implementation? (`"rejects expired tokens"` not `"test_validate_token_3"`)
- Is setup separated from action and assertion? (Arrange-Act-Assert or Given-When-Then)
- Are shared setup blocks (describe/context) used appropriately? (grouping related scenarios, not hiding dependencies)

## Step 5 — Regression Risk Assessment

For the specific changes being audited:
- If a bug were introduced in this code tomorrow, would the current test suite catch it?
- What classes of bugs would slip through? (off-by-one? nil handling? wrong field name? race condition?)
- Are there high-risk code paths with disproportionately low test coverage?
- Are there tests that would need to be updated if the implementation changed, even though the behavior didn't? (brittle tests coupled to implementation)

## Step 6 — Adversarial Challenge

Before presenting, spawn the **adversarial-debate** agent to challenge your quality findings. False gaps waste engineering effort writing unnecessary tests — precision matters.

Format all findings as structured claims and pass them to the agent along with:
- The test files and production files for each finding
- The coverage gap claims with specific branches/paths identified
- The fidelity claims with specific test names and assertion lines

The agent will:
- Verify every file:line reference against current code
- Challenge coverage gaps — "you say this branch is untested, but did you check the integration test at test_file:line that exercises this path?"
- Steel-man existing tests — "you say this assertion is vacuous, but the factory setup guarantees specific values — the shape check IS sufficient here"
- Verify flakiness claims — "you flagged this as time-dependent, but the test uses frozen time via `DateTime.utc_now()` mock"
- Check mock fidelity claims against actual interfaces
- Calibrate severity — distinguish "this gap will let a real bug through" from "this could theoretically be more thorough"

Apply the agent's verdicts:
- **KEEP**: gap is real and risk-justified
- **DOWNGRADE**: adjust severity based on actual risk
- **REVISE**: narrow the claim to what's demonstrated
- **DROP**: remove false gaps — note in "Considered and Dismissed" section

After applying verdicts, confirm:
- [ ] Every surviving coverage gap identifies a realistic bug class it would miss
- [ ] Fidelity claims are verified against actual test code, not assumptions
- [ ] Recommendations are proportional to the risk of the code area

## Step 7 — Report

```markdown
## Quality Audit: [Scope]
Date: [ISO timestamp]

### Summary
[2-3 sentences: overall test quality assessment — is the test suite trustworthy for this area?]

### Critical Findings (tests that give false confidence)
#### 1. [Category]: [Title]
**Location:** `test_file:line`
**Problem:** [Why this test doesn't catch what it claims to]
**Risk:** [What class of bug would slip through]
**Fix:** [Concrete test code or assertion to add/change]

### High Findings (significant coverage gaps)
...

### Medium Findings (test quality improvements)
...

### Low Findings (minor improvements)
...

### Coverage Matrix
| Production Code | Unit Tests | Integration Tests | Gaps |
|----------------|-----------|------------------|------|
| `file:function/arity` | `test:line` | `test:line` | [untested branches/paths] |

### Flakiness Risk
| Test | Risk Factor | Mitigation |
|------|------------|------------|
| `test_file:line` | [time/order/network/race] | [how to stabilize] |

### Test Architecture Assessment
- **Pyramid balance:** [healthy / top-heavy / bottom-heavy]
- **Placement:** [well-organized / misplaced tests identified]
- **Factory quality:** [solid / needs attention]

### Positive Patterns
- [Good testing practices to reinforce]

### Considered and Dismissed
- [Findings that failed adversarial review]

### Recommendations
1. [Prioritized actions — highest risk gaps first]
```

## Guidelines

- A test that passes when the code is broken is WORSE than no test — it creates false confidence
- Focus on tests that catch real bugs, not checkbox coverage — 80% meaningful coverage beats 100% vacuous coverage
- Flaky tests erode trust in the entire suite — flag flakiness risk aggressively
- Test architecture matters — wrong-level tests are expensive to maintain and slow to run
- Be specific about what bugs a gap would miss — "untested" is not a finding, "untested nil handling in user-facing endpoint that would cause 500" is
- Acknowledge good testing practices — teams that test well should know what to keep doing
- Don't recommend tests for trivial code (simple getters, delegation, config) — test effort should match code risk
