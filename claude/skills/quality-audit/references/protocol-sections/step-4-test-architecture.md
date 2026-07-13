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
