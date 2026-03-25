# Gotchas — my-implement

Known failure patterns and lessons learned. Read before starting work with this skill.

### Test isolation / fixture pollution
- **Category:** anti-pattern
- **Context:** Modifying test fixtures that touch singletons, registries, or global state
- **Wrong:** Modifying shared fixture state without save/restore, assuming tests run in isolation
- **Right:** Always save/restore state via setup/teardown. Don't just reset — downstream tests may depend on the original state. Check if the fixture is used by other test files.
- **Why:** Fixture pollution causes flaky tests that pass individually but fail when run as a suite, or fail in CI but pass locally due to different test ordering
- **Source:** Recurring pattern in test suites

### Unique keys in batch/multi operations
- **Category:** edge-case
- **Context:** Building a sequence of keyed operations from a collection (e.g., database multi/transaction builders, bulk inserts, pipeline steps)
- **Wrong:** Using a static key or only the item type as the operation key when iterating over a collection
- **Right:** Ensure operation keys are unique across all items — include the item ID or index in the key (e.g., `("update_record", record.id)`)
- **Why:** Duplicate keys silently overwrite earlier operations, causing data loss or runtime errors that are hard to debug
- **Source:** Recurring pattern in batch operation APIs across languages

### Stage complex cross-service changes
- **Category:** convention
- **Context:** Implementing changes that span multiple services
- **Wrong:** Merging after CI passes, assuming isolated test suites are sufficient
- **Right:** Verify cross-service changes in a staging environment before merge. Interaction bugs between services don't surface in isolated test suites.
- **Why:** Each service's CI only tests its own code. Integration failures (contract mismatches, timing issues, deployment order problems) only appear when services interact
- **Source:** Recurring pattern in polyglot monorepos

### No lazy imports — circular dependency avoidance is NEVER an acceptable reason
- **Category:** convention
- **Context:** Writing or modifying any Python code. This applies when writing new functions, refactoring existing code, or moving code between modules.
- **Wrong:** Using `import X` inside a function body to "avoid circular imports" or "defer loading." This includes: (1) writing new lazy imports, (2) copying the pattern from nearby code that already does it, (3) treating lazy imports as a "pragmatic" solution to ship faster. A common failure: a file has a comment like "no imports from X to avoid circular dependencies," so you cargo-cult the pattern for ALL imports — even ones that have zero circular dependency risk.
- **Right:** All imports at the top of the file. ALWAYS. If a circular import occurs, that is an architecture problem — fix it by extracting shared types, using a registry pattern, or restructuring dependencies. Before writing a lazy import, first verify the circular import actually exists by testing the module-level import. Do not assume it will fail just because nearby code uses lazy imports or the file has a comment about circular imports.
- **Why:** Lazy imports hide dependency relationships, bypass import-time error detection, paper over architecture problems, and create per-call overhead. They are a code smell that indicates poorly organized modules. The cost of fixing the architecture is always worth it — lazy imports accumulate and make the real dependency graph invisible.
- **Source:** Recurring pattern. Most recently: wrote lazy imports in a utility function because the host file "avoids cross-module imports" — but the imports in question were to entirely separate packages with no circular dependency risk. The lazy import was cargo-culted without verification.

### Functions should be declared at module scope, not nested inside other functions
- **Category:** convention
- **Context:** Writing Python business logic
- **Wrong:** Defining helper functions inside other functions when they don't need closure state. Example: `def process(): def helper(): ...; helper()`
- **Right:** Declare functions at module scope as first-class citizens. Pass any needed context as parameters. Exceptions: decorator implementations, factory functions that genuinely need closure state, pytest fixtures.
- **Why:** Nested functions are untestable in isolation, invisible to the module's public surface, and harder to read. They're a code smell indicating the function is doing too much or the module needs better organization.
- **Source:** Recurring pattern in Python codebases
