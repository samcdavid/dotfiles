# General Review Checklist

The cross-cutting review categories that apply to every `my-review` invocation regardless of which lenses are active. Lens-specific checklists live in the dedicated skill files (`security-audit`, `my-arch-review`, `perf-review`, `quality-audit`, `requirements-audit`).

Categories are ordered by priority. Before raising any issue, check it against the existing-comments dedupe index supplied by the caller. Do not re-raise anything already covered by an existing thread.

## Blocking Issues (must fix before merge)

### Correctness / Bugs
- Logic errors, off-by-one, nil/null handling, race conditions
- Database consistency — reads from correct replica? Writes idempotent?
- Backward compatibility — can persisted state, queued jobs, or cached data from before this change cause failures after deploy?
- Cross-service contracts — do serialization formats, field names, nullable/required declarations, and type coercions align across service boundaries?
- Edge case probing — for every pattern match, conditional, and guard: what else could this value be? What happens when the input is nil, an empty list, a negative number, or a type the author didn't anticipate? Ask explicitly.
- Bang vs. non-bang function choice — does a `!` function raise where the caller can't handle it (e.g. `Req.post!` in a user-facing request path)? Does a non-bang function silently swallow errors that should crash?

### Blast Radius
- Does the change scope match the stated intent? Removing a guard or feature flag should not silently broaden behavior beyond what's intended.
- Are there callers or consumers of changed interfaces that aren't updated?
- Are new pattern match branches missing fallback clauses that existing code depends on?

### Layer Boundaries
- Do API/resolver/controller concerns leak into backend contexts or domain modules? (e.g. GraphQL types, HTTP params, response formatting in a context module)
- Does business logic leak into resolvers/controllers that should live in a context?
- If data is transformed for API consumers, does the transform live in the API layer — not buried in the backend?

### Idempotency & Resilience
- Can retries cause duplicates? (jobs, webhooks, API calls)
- Is error handling appropriate? (retry vs. fail-fast vs. dead-letter)
- Signal handling in containers (SIGTERM propagation)
- Unbounded loops or retries — is there a safeguard (max attempts, timeout, circuit breaker)?
- Oban jobs: is uniqueness config correct? (never unique on `args` alone; include/exclude `executing` state as appropriate; `drain_jobs` from `Oban.Pro.Testing` in tests, not `perform_job` unless unit-testing a single worker)

### Transaction Design
- Are Oban jobs enqueued inside the same transaction as the data they depend on? (use `Oban.insert` with `Multi` for atomicity)
- Avoid `Multi.run` when possible — it prevents leveraging transaction callbacks. Prefer `Multi.insert`, `Multi.update`, etc.
- Does `insert_all` vs. `insert` vs. loop-insert match the expected data volume? Bulk operations need `insert_all`, not a loop.

### Migration Safety (if the diff includes migrations)
- NOT NULL constraints on large tables — can this lock the table and cause an outage? Consider adding the constraint as NOT VALID first, then validating separately.
- Down migrations — are they present? Are they safe to run? Will the down migration itself cause data loss?
- Column types — money values should be `numeric(16,2)`, not `integer` or `float`. JSONB columns should have `default: '{}'` to avoid nil checks.
- Advisory locks — is `@disable_migration_lock` still being used unnecessarily? (check if the project uses `migration_lock: :pg_advisory_lock`)
- Stale backfillers — if this migration supersedes an old backfiller, flag the old one for removal.

### Security (baseline — deeper analysis lives in `security-audit/SKILL.md`)
- Input validation at system boundaries
- Auth/authz checks present and correct
- No secrets in code, no SQL injection, no XSS vectors
- Auth tokens must not be exposed to callers other than the authenticated user themselves
- Routes — are new routes appropriately scoped (public vs. authenticated vs. staff-only)?

### Test Fidelity
- Do tests actually test what they claim? (not vacuously passing)
- Are assertions checking the right values/keys? Assert specific error values, not just that an error occurred.
- Is randomness in tests masking deterministic failures?
- Coverage for the critical path — not necessarily 100%, but the important paths

### Test Placement
- Are detailed branching/logic tests at the unit level, close to the function they exercise?
- Integration tests should verify wiring only — one happy-path test to confirm the pieces connect. Branching and edge cases belong in unit tests.
- If a new module or function is added but only tested through a high-level integration test, flag it: the function needs its own unit tests.

### Lint and Tooling Discipline
- Are any lint checks, formatter rules, or static analysis warnings being disabled or suppressed (e.g. `# credo:disable-for-this-file`, `# noqa`, `# eslint-disable`, `# rubocop:disable`, `@dialyzer`, `mix format` skip comments)?
- Every disabled check is a **blocking issue** unless the author provides a valid justification. "Valid" means: the rule genuinely does not apply to this specific case (not "it's inconvenient" or "the code doesn't pass").
- Common invalid justifications: disabling formatting rules to preserve manual formatting, disabling import-order checks, suppressing warnings instead of fixing them, disabling type checks because a type is hard to express.
- If a disable comment already existed and the PR didn't add it, it's not a blocking issue — but flag it as a question ("is this still needed?").

### Requirements Traceability (if a requirements checklist was supplied by the caller)
- For each requirement/acceptance criterion, identify which file(s) and change(s) address it. Flag any requirement with no corresponding code change as a **blocking issue** (missing requirement).
- For each code change that doesn't trace back to any requirement, flag it as a **question** (unplanned scope — may be intentional, but the author should confirm).

### Related-Issue Regression (if `requirements-tracer` was spawned)
- For each `At-risk` finding from the tracer where the regression is `Likely-breakage`, flag as a **blocking issue** — name the related Linear issue, the surface, and the call chain (`file:line`).
- For `At-risk` findings classified `Behavior-shift-unverified` (tracer couldn't fully verify the contract is preserved), flag as a **non-blocking question** asking the author to confirm.
- For `At-risk` findings where the tracer's Test Coverage verdict is `No-test-found` or `Unlikely`, additionally flag a **non-blocking suggestion** to add a regression test, naming the specific behavior to cover.
- Do NOT re-raise tracer findings already in the existing-comments index (dedupe still applies).

## Non-blocking Suggestions (improvements, not blockers)

### Performance (baseline — deeper analysis lives in `perf-review/SKILL.md`)
- Primary vs. follower repo for read-only queries
- N+1 queries, missing indexes, unbounded result sets
- Unnecessary computation, missing caching opportunities
- Index alignment — does the query use operators that can leverage existing indexes? (e.g. `@>` uses GIN indexes, `->>` with `=` does not)
- App-side filtering that could be a SQL WHERE clause — move filtering into the query when the dataset could be large
- `insert_all` for bulk operations instead of looping `insert` — flag loops that insert/update in a loop when a bulk operation would work

### Existing Pattern Reuse
- Does the codebase already have a utility, function, or module that does what this new code adds? Flag duplication. (The `codebase-pattern-finder` subagent should surface these — reference its findings here.)
- Does the project have a conventional way to do this (e.g. a factory helper in tests, a shared changeset function, a query module)? New code should follow existing patterns.

### Code Cleanliness
- Dead code, unused imports, orphaned fields, stale backfillers
- Import organization
- Design system consistency (tokens vs. raw values)
- Changeset design — are create and update operations using separate changeset functions? Overloading a single `changeset/2` for both create and update makes future changes riskier.

### Naming and Domain Precision
- Do names match domain concepts precisely? A variable called `type` when it means `screener_type` costs future readers cognitive effort.
- Magic numbers/strings should be extracted to named constants.
- Temporary fields or workarounds should be documented: why is it needed, how do we know when it can be removed?

### Clarity for Future Readers
- Comments explaining "why not" for non-obvious decisions
- Guards scoped to known types rather than catch-all else clauses
- Log levels — is the level appropriate for the severity? (`info` for normal operations, `warning` for degraded but functional, `error` for failures that need attention)

### Forward-Looking Design
- Will this structure make known upcoming refactors harder? If the code reinforces associations or patterns that are slated to change, flag it as a question.
- Could data be structured differently now to avoid a future migration? (not speculative — only flag when there's a known initiative)
