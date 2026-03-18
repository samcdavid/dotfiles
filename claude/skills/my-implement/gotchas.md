# Gotchas — my-implement

Known failure patterns and lessons learned. Read before starting work with this skill.

### Test isolation / fixture pollution
- **Category:** anti-pattern
- **Context:** Modifying test fixtures that touch singletons, registries, or global state
- **Wrong:** Modifying shared fixture state without save/restore, assuming tests run in isolation
- **Right:** Always save/restore state via setup/teardown. Don't just reset — downstream tests may depend on the original state. Check if the fixture is used by other test files.
- **Why:** Fixture pollution causes flaky tests that pass individually but fail when run as a suite, or fail in CI but pass locally due to different test ordering
- **Source:** Recurring pattern in test suites

### Ecto.Multi key uniqueness
- **Category:** edge-case
- **Context:** Generating Ecto.Multi operations from collections (e.g., bulk inserts/updates)
- **Wrong:** Using a static key or only the item type as the Multi key when iterating over a collection
- **Right:** Ensure Multi keys are unique across all items — include the item ID or index in the key (e.g., `{:update_record, record.id}`)
- **Why:** Duplicate Multi keys silently overwrite earlier operations, causing data loss or runtime crashes that are hard to debug
- **Source:** Recurring pattern in Elixir codebases

### Stage complex cross-service changes
- **Category:** convention
- **Context:** Implementing changes that span multiple services
- **Wrong:** Merging after CI passes, assuming isolated test suites are sufficient
- **Right:** Verify cross-service changes in a staging environment before merge. Interaction bugs between services don't surface in isolated test suites.
- **Why:** Each service's CI only tests its own code. Integration failures (contract mismatches, timing issues, deployment order problems) only appear when services interact
- **Source:** Recurring pattern in polyglot monorepos
