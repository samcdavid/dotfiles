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

### No lazy imports — imports belong at module top level
- **Category:** convention
- **Context:** Writing Python code that needs to import a module
- **Wrong:** Using `import X` inside a function body to "avoid circular imports" or "defer loading." Example: `def my_func(): import yaml; yaml.dump(...)`
- **Right:** All imports at the top of the file. If a circular import occurs, fix the module architecture (extract shared types, use a registry pattern, restructure dependencies). The only valid exception is genuinely expensive imports (e.g., SpaCy model loading) where startup cost matters.
- **Why:** Lazy imports hide dependency relationships, bypass import-time error detection, and paper over architecture problems. They make it impossible to see a module's dependencies at a glance.
- **Source:** ENA-184 — wrote `import yaml` inside `_cmd_list_versions` when yaml was already loaded transitively

### Functions should be declared at module scope, not nested inside other functions
- **Category:** convention
- **Context:** Writing Python business logic
- **Wrong:** Defining helper functions inside other functions when they don't need closure state. Example: `def process(): def helper(): ...; helper()`
- **Right:** Declare functions at module scope as first-class citizens. Pass any needed context as parameters. Exceptions: decorator implementations, factory functions that genuinely need closure state, pytest fixtures.
- **Why:** Nested functions are untestable in isolation, invisible to the module's public surface, and harder to read. They're a code smell indicating the function is doing too much or the module needs better organization.
- **Source:** ENA-184 code conventions discussion
