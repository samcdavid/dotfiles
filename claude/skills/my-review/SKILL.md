---
name: my-review
description: Rigorous code review modeled on OSS standards. Reviews local changes or GitHub PRs for correctness, cross-service contracts, idempotency, test fidelity, and performance. De-duplicates against existing review comments. Researches the codebase to verify findings.
disable-model-invocation: true
---

# Code Review

Perform a thorough, high-quality code review. Works on local changes (unstaged/staged/committed) or GitHub pull requests.

## Getting Started

Determine what to review:
- If `$ARGUMENTS` contains a PR number or URL → **PR Mode** (fetch the PR diff via `gh`)
- If `$ARGUMENTS` is empty or `local` → **Local Mode** (review working tree changes via `git diff`)
- If `$ARGUMENTS` contains a branch name → review diff against that branch

## Step 0 — Choose Review Persona

Ask me which persona I want the review performed as. The persona determines what you prioritize, what you scrutinize most deeply, and what you're willing to let slide.

**Common personas** (not exhaustive — I can request any lens):

| Persona | Focus | Deep Review Behavior |
|---------|-------|---------------------|
| **Backend** | Data integrity, query performance, idempotency, error handling, transaction design, race conditions, job safety | Trace every database write for idempotency. Verify Oban job uniqueness and transaction boundaries. Check that reads hit the correct replica. Evaluate error handling strategy (retry vs. fail-fast vs. dead-letter) for each failure mode. Profile N+1 queries and missing indexes. |
| **Frontend** | Accessibility, responsive behavior, state management, render performance, UX consistency, design system adherence | Audit every interactive element for ARIA attributes and keyboard navigation. Check for unnecessary re-renders and state management anti-patterns. Verify design system token usage vs. raw values. Test responsive breakpoint logic. Evaluate loading/error/empty states for every async operation. |
| **Security** | Auth/authz, input validation, injection vectors, secrets exposure, CORS/CSP, token handling, OWASP top 10 | Trace every user input from entry point through processing to storage and output. Verify auth checks exist at the data layer, not just UI. Check for IDOR vectors. Audit token exposure in logs, URLs, and error messages. Validate CORS and CSP configuration. |
| **Architect** | System boundaries, coupling, abstraction quality, scalability implications, API contract design, migration paths | Map dependency directions between changed modules. Evaluate whether new code follows or breaks established layering. Check for hidden coupling (shared mutable state, temporal coupling, implicit contracts). Assess whether the pattern scales if repeated 10x. |
| **PM** | Requirements coverage, acceptance criteria traceability, scope creep, user-facing behavior changes, feature completeness | Fetch the linked Linear ticket and build a requirements checklist. Map every acceptance criterion to specific code changes. Flag requirements with no corresponding code (missing) and code with no corresponding requirement (scope creep). Verify user-facing behavior matches the spec — not just that code runs, but that it does what was asked. |
| **Ops** | Deployment safety, observability, failure modes, rollback paths, resource usage, configuration management | Check for missing health checks, readiness probes, and graceful shutdown handling. Verify logging captures enough context for debugging without leaking sensitive data. Evaluate feature flags and rollback paths. Check for unbounded resource consumption (memory leaks, connection pool exhaustion, disk usage). Assess migration rollback safety. Verify environment-specific configuration is externalized. |
| **Quality** | Test fidelity, coverage gaps, assertion quality, flakiness risk, test architecture, regression safety | Verify tests actually catch what they claim — not vacuously passing. Check both sides of every conditional are tested. Evaluate assertion specificity (exact values vs. shape checks). Flag flakiness risk (time-dependent, order-dependent, async race conditions). Assess test pyramid balance and placement. Identify high-risk code with disproportionately low coverage. |

If I provide a custom persona not listed above, adapt the review priorities to match what that role would care about most. Use the same depth pattern: identify the domain-specific concerns, trace them through the code, and verify they're handled correctly.

If I say "all" or "full", run the review without a specific lens (current default behavior).

**Apply the persona throughout the entire review** — it should influence:
- Which categories in Step 5 get the deepest scrutiny
- What counts as blocking vs. non-blocking
- What questions get asked
- What gets called out as good

Do NOT proceed until I've chosen a persona.

## Step 1 — Gather the Diff and Existing Feedback

**PR Mode:**
```bash
gh pr diff <number>
gh pr view <number>
gh pr view <number> --json files --jq '.files[].path'
```

Also fetch ALL existing review comments and conversation threads:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate
gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate
```

Build an index of every issue already raised — file path, line range, and substance of the comment. You will use this to DE-DUPLICATE your review. Do not re-raise anything that has already been flagged, discussed, or resolved in an existing thread.

**Local Mode:**
```bash
git diff                    # unstaged
git diff --cached           # staged
git log --oneline -5        # recent commits for context
```

Read EVERY changed file fully — not just the diff hunks. You need surrounding context to review properly.

## Step 2 — Understand Intent and Requirements

Before reviewing code, understand WHAT the change is trying to accomplish:
- PR description, commit messages, or linked issues
- Ask the user if intent is unclear — don't guess

**Requirements traceability (PR Mode):** If the PR description links to a Linear ticket (e.g. `ENG-123`, `Fixes ENG-123`, Linear URL), fetch it:
```bash
# Use the Linear MCP tools to fetch the ticket
# Extract: title, description, acceptance criteria, sub-issues
```
Build a **requirements checklist** from the ticket. You will use this in Step 5 to verify every requirement is addressed and flag any code changes that don't trace back to a requirement (scope creep).

If no ticket is linked, note this as an observation (not a blocking issue) and proceed with intent from the PR description alone.

State your understanding of the intent back to the user before proceeding:
> "Here's what I understand this change does and why — is this correct?"

This catches misunderstandings before they become incorrect review comments.

## Step 3 — Research the Codebase

Spawn parallel agents to build a grounded understanding of the code being changed:
- **codebase-analyzer**: Deep-read the changed files AND their callers/consumers. Understand how the changed code fits into the larger system — call chains, data flow, dependencies.
- **codebase-pattern-finder**: Find how similar changes were made elsewhere in the codebase. Identify conventions that this change should follow. **Specifically check whether the codebase already has a utility, function, or module that does what any new code is adding.** Duplicating existing functionality is a common review finding — flag it.

This step ensures your review is based on ACTUAL CODE, not assumptions. Do not skip it.

## Step 4 — Research Dependencies

Spawn a **docs-researcher** agent for any:
- New dependencies added
- APIs or library functions used in ways you're not 100% certain are correct
- Framework patterns that might have version-specific behavior

Do NOT review library usage without checking the actual docs. Incorrect API usage that "looks right" is a common source of bugs.

## Step 5 — Systematic Review

Review the changes against these categories, ordered by priority.

**Before raising any issue, check it against the existing comments index from Step 1. If the issue has already been raised, skip it entirely.** If an existing comment is incomplete or misses a nuance, you may ADD to it but not repeat it.

### Blocking Issues (must fix before merge)

**Correctness / Bugs**
- Logic errors, off-by-one, nil/null handling, race conditions
- Database consistency — reads from correct replica? Writes idempotent?
- Backward compatibility — can persisted state, queued jobs, or cached data from before this change cause failures after deploy?
- Cross-service contracts — do serialization formats, field names, nullable/required declarations, and type coercions align across service boundaries?
- Edge case probing — for every pattern match, conditional, and guard: what else could this value be? What happens when the input is nil, an empty list, a negative number, or a type the author didn't anticipate? Ask explicitly.
- Bang vs. non-bang function choice — does a `!` function raise where the caller can't handle it (e.g. `Req.post!` in a user-facing request path)? Does a non-bang function silently swallow errors that should crash?

**Blast Radius**
- Does the change scope match the stated intent? Removing a guard or feature flag should not silently broaden behavior beyond what's intended.
- Are there callers or consumers of changed interfaces that aren't updated?
- Are new pattern match branches missing fallback clauses that existing code depends on?

**Layer Boundaries**
- Do API/resolver/controller concerns leak into backend contexts or domain modules? (e.g. GraphQL types, HTTP params, response formatting in a context module)
- Does business logic leak into resolvers/controllers that should live in a context?
- If data is transformed for API consumers, does the transform live in the API layer — not buried in the backend?

**Idempotency & Resilience**
- Can retries cause duplicates? (jobs, webhooks, API calls)
- Is error handling appropriate? (retry vs. fail-fast vs. dead-letter)
- Signal handling in containers (SIGTERM propagation)
- Unbounded loops or retries — is there a safeguard (max attempts, timeout, circuit breaker)?
- Oban jobs: is uniqueness config correct? (never unique on `args` alone; include/exclude `executing` state as appropriate; `drain_jobs` from `Oban.Pro.Testing` in tests, not `perform_job` unless unit-testing a single worker)

**Transaction Design**
- Are Oban jobs enqueued inside the same transaction as the data they depend on? (use `Oban.insert` with `Multi` for atomicity)
- Avoid `Multi.run` when possible — it prevents leveraging transaction callbacks. Prefer `Multi.insert`, `Multi.update`, etc.
- Does `insert_all` vs. `insert` vs. loop-insert match the expected data volume? Bulk operations need `insert_all`, not a loop.

**Migration Safety** (if the diff includes migrations)
- NOT NULL constraints on large tables — can this lock the table and cause an outage? Consider adding the constraint as NOT VALID first, then validating separately.
- Down migrations — are they present? Are they safe to run? Will the down migration itself cause data loss?
- Column types — money values should be `numeric(16,2)`, not `integer` or `float`. JSONB columns should have `default: '{}'` to avoid nil checks.
- Advisory locks — is `@disable_migration_lock` still being used unnecessarily? (check if the project uses `migration_lock: :pg_advisory_lock`)
- Stale backfillers — if this migration supersedes an old backfiller, flag the old one for removal.

**Security**
- Input validation at system boundaries
- Auth/authz checks present and correct
- No secrets in code, no SQL injection, no XSS vectors
- Auth tokens must not be exposed to callers other than the authenticated user themselves
- Routes — are new routes appropriately scoped (public vs. authenticated vs. staff-only)?

**Test Fidelity**
- Do tests actually test what they claim? (not vacuously passing)
- Are assertions checking the right values/keys? Assert specific error values, not just that an error occurred.
- Is randomness in tests masking deterministic failures?
- Coverage for the critical path — not necessarily 100%, but the important paths

**Test Placement**
- Are detailed branching/logic tests at the unit level, close to the function they exercise?
- Integration tests should verify wiring only — one happy-path test to confirm the pieces connect. Branching and edge cases belong in unit tests.
- If a new module or function is added but only tested through a high-level integration test, flag it: the function needs its own unit tests.

**Lint and Tooling Discipline**
- Are any lint checks, formatter rules, or static analysis warnings being disabled or suppressed (e.g. `# credo:disable-for-this-file`, `# noqa`, `# eslint-disable`, `# rubocop:disable`, `@dialyzer`, `mix format` skip comments)?
- Every disabled check is a **blocking issue** unless the author provides a valid justification. "Valid" means: the rule genuinely does not apply to this specific case (not "it's inconvenient" or "the code doesn't pass").
- Common invalid justifications: disabling formatting rules to preserve manual formatting, disabling import-order checks, suppressing warnings instead of fixing them, disabling type checks because a type is hard to express.
- If a disable comment already existed and the PR didn't add it, it's not a blocking issue — but flag it as a question ("is this still needed?").

**Requirements Traceability** (if a requirements checklist was built in Step 2)
- For each requirement/acceptance criterion, identify which file(s) and change(s) address it. Flag any requirement with no corresponding code change as a **blocking issue** (missing requirement).
- For each code change that doesn't trace back to any requirement, flag it as a **question** (unplanned scope — may be intentional, but the author should confirm).

### Non-blocking Suggestions (improvements, not blockers)

**Performance**
- Primary vs. follower repo for read-only queries
- N+1 queries, missing indexes, unbounded result sets
- Unnecessary computation, missing caching opportunities
- Index alignment — does the query use operators that can leverage existing indexes? (e.g. `@>` uses GIN indexes, `->>` with `=` does not)
- App-side filtering that could be a SQL WHERE clause — move filtering into the query when the dataset could be large
- `insert_all` for bulk operations instead of looping `insert` — flag loops that insert/update in a loop when a bulk operation would work

**Existing Pattern Reuse**
- Does the codebase already have a utility, function, or module that does what this new code adds? Flag duplication. (Step 3's pattern-finder should surface these — reference its findings here.)
- Does the project have a conventional way to do this (e.g. a factory helper in tests, a shared changeset function, a query module)? New code should follow existing patterns.

**Code Cleanliness**
- Dead code, unused imports, orphaned fields, stale backfillers
- Import organization
- Design system consistency (tokens vs. raw values)
- Changeset design — are create and update operations using separate changeset functions? Overloading a single `changeset/2` for both create and update makes future changes riskier.

**Naming and Domain Precision**
- Do names match domain concepts precisely? A variable called `type` when it means `screener_type` costs future readers cognitive effort.
- Magic numbers/strings should be extracted to named constants.
- Temporary fields or workarounds should be documented: why is it needed, how do we know when it can be removed?

**Clarity for Future Readers**
- Comments explaining "why not" for non-obvious decisions
- Guards scoped to known types rather than catch-all else clauses
- Log levels — is the level appropriate for the severity? (`info` for normal operations, `warning` for degraded but functional, `error` for failures that need attention)

**Forward-Looking Design**
- Will this structure make known upcoming refactors harder? If the code reinforces associations or patterns that are slated to change, flag it as a question.
- Could data be structured differently now to avoid a future migration? (not speculative — only flag when there's a known initiative)

### Escalation to Dedicated Skills (Auto-triggered)

After completing the Step 5 review, evaluate whether the changes warrant escalation to a dedicated skill for deeper analysis. **Recommend escalation — do not silently skip it.** Present the recommendation and let me confirm or decline before running.

#### → `/security-audit`
Escalate when the diff touches ANY of:
- Authentication or authorization logic (auth, session, token, permission, policy)
- Input parsing or validation (params, body, query, headers, deserialization)
- Database queries constructed with user input
- File upload/download handling
- External API credential usage
- CORS, CSP, or security header configuration

Incorporate findings into the review under a dedicated "Security Deep-Dive" subsection.

#### → `/my-arch-review`
Escalate when the diff includes ANY of:
- New modules, services, or top-level directories
- Changes to module boundaries, public interfaces, or cross-module imports
- New dependency directions (module A now imports module B for the first time)
- Significant refactors that move code between layers or modules
- New infrastructure patterns (new queue consumers, new API gateways, new caching layers)

Incorporate findings into the review under a dedicated "Architecture Assessment" subsection.

#### → `/perf-review`
Escalate when the diff touches ANY of:
- Database queries on known large tables or with missing/mismatched indexes
- Hot request paths (high-traffic endpoints, real-time features)
- Background job scheduling, concurrency, or queue configuration
- Caching logic (cache reads, writes, invalidation, TTL changes)
- Loops or iterations over potentially unbounded data sets
- Connection pool configuration or external service call patterns

Incorporate findings into the review under a dedicated "Performance Deep-Dive" subsection.

#### → `/requirements-audit`
Escalate when ANY of:
- The PR links to a Linear ticket with detailed acceptance criteria (>3 criteria)
- The PR description references a spec, RFC, or design doc
- The change introduces new user-facing behavior (new endpoints, UI changes, notification logic)
- The PM persona is selected (always recommend — the dedicated audit goes deeper)
- Multiple requirements-related questions arise during the review

Incorporate findings into the review under a dedicated "Requirements Traceability" subsection.

#### → `/quality-audit`
Escalate when ANY of:
- Tests are added or significantly modified in the PR
- New modules or services are added without corresponding test files
- Test assertions look vacuous (shape checks only, `assert true`, broad pattern matches)
- Mocks or stubs are used extensively — fidelity risk warrants dedicated analysis
- The quality persona is selected (always recommend — the dedicated audit goes deeper)
- The change touches high-risk code (payments, auth, data mutations) and test coverage looks thin

Incorporate findings into the review under a dedicated "Quality Deep-Dive" subsection.

#### General escalation signals
Beyond the specific triggers above, recommend escalation whenever you notice:
- The change is large enough (>500 lines, >10 files) that a single-pass review may miss systemic issues
- The persona selected doesn't cover a concern you spotted (e.g. reviewing as "backend" but you noticed auth changes — recommend security escalation)
- Multiple review categories are raising related concerns that suggest a deeper structural problem

**Format the escalation recommendation:**
```
### Recommended Escalations
- `/security-audit` — [reason: what triggered it, which files]
- `/my-arch-review` — [reason: what triggered it, which files]
- `/perf-review` — [reason: what triggered it, which files]
- `/requirements-audit` — [reason: what triggered it, which files]
- `/quality-audit` — [reason: what triggered it, which files]

Run these? (y/n/select)
```

If I decline, continue with the review as-is. If I select specific ones, run only those.

## Step 6 — Format the Review

Structure the review as follows:

```markdown
## Review: [Brief description of what the change does]

### Summary
[1-2 sentences demonstrating you understood the change and its purpose]

### Blocking Issues

#### 1. [Category]: [Concise issue title]
**File:** `path/to/file.ext:LINE`
**Problem:** [What's wrong and why it matters]
**Fix:**
[Concrete code suggestion — copy-pasteable, not vague guidance]

### Non-blocking Suggestions

#### 1. [Category]: [Concise title]
**File:** `path/to/file.ext:LINE`
**Suggestion:** [What to improve and why]
**Example:**
[Code snippet if helpful]

### Requirements Traceability
[Only if a Linear ticket was linked — skip this section otherwise]
| Requirement | Status | File(s) |
|---|---|---|
| [Acceptance criterion] | Covered / Missing / Partial | `path:line` |

### Questions
- [Genuine clarifying questions — things where the author has context you don't]

### What's Good
- [Specific positive callouts — not filler, real recognition of good decisions]

### Dropped Findings
- [Findings that failed adversarial self-review — what was considered and why it was dropped]
```

## Step 7 — Adversarial Challenge

Before presenting the review, spawn the **adversarial-debate** agent to challenge every finding.

Format all blocking issues and non-blocking suggestions as structured findings and pass them to the agent along with:
- The PR diff
- The file paths referenced in findings
- The requirements checklist (if built in Step 2)

The agent will return a verdict for each finding: KEEP, DOWNGRADE, REVISE, or DROP — with evidence.

Apply the agent's verdicts:
- **KEEP**: present as-is
- **DOWNGRADE**: move from blocking to non-blocking, or from finding to question
- **REVISE**: update the claim or fix based on the agent's feedback
- **DROP**: remove entirely and note in the "Dropped Findings" section

If a finding is revised, retry the adversarial challenge on the revision (max 2 retries). If it still fails, drop it.

### Post-Challenge Checklist

After applying verdicts, confirm:
- [ ] Blocking vs. non-blocking classification reflects the agent's severity calibration
- [ ] Dependency docs were checked for any non-obvious API usage
- [ ] No comment duplicates anything already raised in existing review threads
- [ ] Findings are grounded in the codebase research from Step 3, not assumptions

## Guidelines

- Every blocking issue MUST include a concrete fix — write the actual replacement code, not a vague description of what to change
- Every non-blocking suggestion SHOULD include example code when the alternative isn't obvious
- Explicitly label severity on every comment: **Bug:**, **Suggestion (non-blocking):**, **Question:**, **Nit:**
- Ask rather than demand for things where the author may have context you lack — phrase as "Should we...?", "Could we...?", "WDYT of...?" rather than directives
- Focus on SUBSTANCE — don't bikeshed formatting, naming, or style unless genuinely confusing
- Cross-service boundaries deserve extra scrutiny — this is where subtle bugs hide
- Tests should test what they claim to test — vacuously passing tests are worse than no tests
- NEVER re-raise an issue that already exists in the PR conversation — add to it or skip it
- Reserve blocking status for things that would break production, lose data, or create security vulnerabilities — do not over-block on style or preference

## References

This skill has reference files in `references/` — consult them during review:
- `references/cross-service-contracts.md` — checklist for cross-service changes

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
