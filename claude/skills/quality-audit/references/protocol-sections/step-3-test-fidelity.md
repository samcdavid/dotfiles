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
