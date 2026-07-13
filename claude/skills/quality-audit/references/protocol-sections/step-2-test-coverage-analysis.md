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
