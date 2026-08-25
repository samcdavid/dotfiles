# General Review Checklist

The cross-cutting review categories that apply to every `my-review` invocation regardless of which lenses are active. Lens-specific checklists live in the dedicated skill files (`security-audit`, `my-arch-review`, `perf-review`, `quality-audit`, `requirements-audit`).

Categories are ordered by priority. Before raising any issue, check it against the existing-comments dedupe index supplied by the caller. Do not re-raise anything already covered by an existing thread.

## Critical Candidates (request changes only if verified High risk and merge-blocking)

### Correctness / Bugs
- Logic errors, off-by-one, nil/null handling, race conditions
- Database consistency — reads from correct replica? Writes idempotent?
- Backward compatibility — can persisted state, queued jobs, or cached data from before this change cause failures after deploy?
- Cross-service contracts — do serialization formats, field names, nullable/required declarations, and type coercions align across service boundaries?
- Edge case probing — for every pattern match, conditional, and guard: what else could this value be? What happens when the input is nil, an empty list, a negative number, or a type the author didn't anticipate? Ask explicitly.
- Bang vs. non-bang function choice — does a `!` function raise where the caller can't handle it (e.g. `Req.post!` in a user-facing request path)? Does a non-bang function silently swallow errors that should crash?
- **Claim verification** — a comment, docstring, or PR-body sentence that asserts a fact about the live system (a DB column has no NOT NULL constraint, an ADR requirement is satisfied or doesn't apply, a GIN index is the right choice given the query's selectivity, "this fix handles the real input") is a claim, not evidence. Check it against the actual source: the real schema/migration history, the ADR's actual text, an actual query plan (`EXPLAIN`), or the real production-shaped input run through the real code path — not synthetic examples. A plausible-sounding prose justification that doesn't survive this check is a Critical finding, not a nit about wording.

### Blast Radius
- Does the change scope match the stated intent? Removing a guard or feature flag should not silently broaden behavior beyond what's intended.
- Are there callers or consumers of changed interfaces that aren't updated?
- Are new pattern match branches missing fallback clauses that existing code depends on?
- **Stale imports / aliases after deletions** — when the diff removes a file, module, function, or class, grep the codebase for any remaining import statements, aliases, `require`/`use`/`from … import`, or re-export references that still name the deleted artifact. Any hit outside the diff is Critical when it will cause a compile or runtime error. Grep by the module path *and* by the exported symbol name; they may be imported separately. In PR Mode, read the diff for all `-` lines that indicate removals and construct the grep targets from those identifiers.
- **Zero-consumer code is not lower-risk.** New foundational or greenfield code (a new DSL, semantic model, composition primitive) with no current callers still gets full correctness scrutiny — "nothing depends on it yet" is a reason bugs are cheap to fix now, not a reason to soften the review. Don't let apparent low blast-radius become an excuse to skim.

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
- A newly disabled check is Critical only when it can hide a production, security, data, contract, or launch-critical correctness issue; otherwise raise a non-blocking question or suggestion. "Valid" means: the rule genuinely does not apply to this specific case (not "it's inconvenient" or "the code doesn't pass").
- Common invalid justifications: disabling formatting rules to preserve manual formatting, disabling import-order checks, suppressing warnings instead of fixing them, disabling type checks because a type is hard to express.
- If a disable comment already existed and the PR didn't add it, it is not Critical — but flag it as a question ("is this still needed?").

### Requirements Traceability (if a requirements checklist was supplied by the caller)
- For each requirement/acceptance criterion, identify which file(s) and change(s) address it. Classify a missing requirement as Critical only when it is must-have for launch; otherwise raise a non-blocking requirements gap or question.
- For each code change that doesn't trace back to any requirement, flag it as a **question** (unplanned scope — may be intentional, but the author should confirm).

### Related-Issue Regression (if `requirements-tracer` was spawned)
- For each `At-risk` finding from the tracer where the regression is `Likely-breakage`, classify as Critical only when the likely regression is merge-blocking; name the related Linear issue, surface, and call chain (`file:line`).
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

### Observability (new metrics, indexes, or telemetry)
- A new index, metric, or log field being emitted is not the same as it being populated with real, non-degenerate data — trace the value's actual source. A field hardcoded to a constant, or populated only behind a rarely-true condition, makes an index built on it permanently empty even though the migration and the code both look correct.
- Confirm the chosen metric type's semantics actually hold for the backend in use — e.g. a gauge assumed to be "sticky" (persists between reporting intervals) that isn't on the actual metrics backend (DogStatsD does not guarantee this) will produce a gapped or unreadable series, not the continuous one the PR intends.

### Existing Pattern Reuse
- Does the codebase already have a utility, function, or module that does what this new code adds? Flag duplication. (The `codebase-pattern-finder` subagent should surface these — reference its findings here.)
- Does the project have a conventional way to do this (e.g. a factory helper in tests, a shared changeset function, a query module)? New code should follow existing patterns.

### Unnecessary Complexity
- Speculative abstractions, generic layers, or config knobs added for a use case the spec/ticket doesn't ask for — flag with a concrete simpler alternative, not just "this feels complex."
- New indirection (an interface, strategy pattern, plugin registry, extra module/service) wrapping a single current implementation — is it earning its cost yet, or would a direct call/function be just as maintainable and easier to read?
- Preemptive generalization ("might need this for other cases later") with no second use case stated in the ticket/spec — the flexibility is a cost paid now for a benefit that may never arrive.
- Could the same requirement ship with fewer new files, fewer new abstractions, or by reusing an existing pattern instead? Name the simpler alternative concretely — this is what makes it an actionable suggestion instead of a vibe.

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
