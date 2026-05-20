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

## Step 1 — Gather the Diff and Existing Feedback

**PR Mode — read-only via `gh`, never check out the branch.**

The PR diff is the source of truth. The local working tree is NOT — `main` is often behind remote, and other PR branches may not exist locally. Do not try to reach the PR's code through the filesystem.

**HARD CONSTRAINTS (PR Mode):**
- NEVER run `git checkout <branch>`, `git switch <branch>`, `gh pr checkout`, `git fetch origin pull/N/head:<name>`, or any command that changes the working tree, creates a local branch ref, or attempts to "get on" the PR branch.
- NEVER read PR-changed files from the local filesystem (`Read`, `cat`, `grep` on disk paths) and treat the result as the PR's code — that reads `main` (or whatever is checked out), not the PR.
- NEVER compare the PR against local `main` as a substitute for the PR diff. Local `main` is not authoritative; it may lag remote by days.
- The ONLY ways to read PR code are: `gh pr diff <number>` for the diff, and `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` for full file contents at PR HEAD (sha from `gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha'`).

```bash
gh pr diff <number>
gh pr view <number>
gh pr view <number> --json files --jq '.files[].path'

# Full file contents at PR HEAD (when the diff alone isn't enough context):
sha=$(gh api repos/{owner}/{repo}/pulls/<number> --jq '.head.sha')
gh api repos/{owner}/{repo}/contents/<path>?ref=$sha --jq '.content' | base64 -d
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

## Step 2 — Cursory Pass: Identify Review Lenses

Before going deep, do a quick triage to pick which review **lenses** apply. Lenses determine which agents get spawned in Step 3, with what prompts, and which categories get the deepest scrutiny in Step 5.

### Inputs

- PR description, commit messages
- Linked Linear issue(s), referenced specs / RFCs / design docs (fetch them — don't infer)
- File-level scan of the diff: which areas changed? (backend / frontend / migrations / config / infra / tests / docs / dependency manifests)
- Existing reviewer assignments or labels on the PR (a hint about what others already think is in scope)

### Lens catalog

Pick lenses that fit. Multiple lenses normally apply.

| Lens | Scrutinizes | Trigger signals |
|---|---|---|
| **Backend** | Data integrity, query performance, idempotency, error handling, transactions, race conditions, job safety | Server-side code, contexts, schemas, queries, jobs, workers |
| **Frontend** | Accessibility, responsive behavior, state management, render performance, UX consistency, design system adherence | UI components, hooks, stores, CSS, design tokens |
| **Full-stack** | Backend + Frontend with cross-layer wiring scrutiny | Both areas touched in one change |
| **Security** | Auth/authz, input validation, injection vectors, secrets, CORS/CSP, token handling | Auth code, input handlers, queries with user input, file upload, external API creds, security headers |
| **Architecture** | System boundaries, coupling, abstraction quality, scalability, contract design, migration paths | New modules/services, changes to module boundaries, new dependency directions, new infra patterns |
| **Ops** | Deployment safety, observability, failure modes, rollback paths, resource usage, configuration | Health checks, logging, feature flags, config files, deploy manifests, env vars, resource limits |
| **QA** | Test fidelity, coverage gaps, assertion quality, flakiness, test architecture | Test files added/modified, mocks/stubs, new modules without tests |
| **PM** | Requirements coverage, acceptance criteria traceability, scope creep, user-facing behavior | Linked ticket with detailed acceptance criteria, new user-facing behavior |
| **Performance** | Hot-path queries, N+1, caching, indexes, unbounded loops, large-table queries | Queries on large tables, hot endpoints, queue/concurrency changes, caching logic |
| **Migration safety** | Lock risk, down-migration safety, column types, advisory locks, backfillers | Migration files in the diff |
| **Dependency** | License, maintenance, attack surface of new packages | Lockfile changes, new dependency manifests |

If the change has no obvious lens fit, default to **Backend + Security + QA**.

### Requirements checklist (if a ticket is linked)

If the PR description links to a Linear ticket (e.g. `ENG-123`, `Fixes ENG-123`, Linear URL), fetch it via the Linear MCP and build a **requirements checklist**: title, description, acceptance criteria, sub-issues. This feeds the PM lens in Step 3 and the requirements-traceability check in Step 5.

If no ticket is linked, note as an observation and proceed with intent from the PR description alone.

### Triage output

Produce a short triage block and show it to me before going deep:

```
### Review Triage
- **Intent:** <1–2 sentences in your words — what this change does and why>
- **Lenses identified:**
  - <Lens> — <one-line rationale grounded in the diff>
  - <Lens> — <one-line rationale grounded in the diff>
- **Auto-escalations queued:**
  - `/security-audit` — <which trigger matched>
  - `/my-arch-review` — <which trigger matched>
  - (or: "none — no triggers matched")
- **Requirements checklist:** built from <ticket ID> | none linked
- **Author calibration (PR Mode):** <Junior | Mid | Senior | Lead | Staff+> — see below
```

Proceed automatically unless I override. Auto-escalation triggers are listed under Step 3.

### Author Skill Level (PR Mode only)

Ask which skill level to calibrate against. Skip for Local Mode.

| Level | Calibration |
|---|---|
| **Junior** | Thorough and educational. Explain *why*. Encouraging on good work. |
| **Mid** | Standard. Explain non-obvious issues. Trust they can implement fixes given a clear problem description. |
| **Senior** | Concise and direct. Focus on subtle bugs and architecture. Skip explanations of well-known patterns. |
| **Lead** | Concise and strategic. Maintainability, team-wide impact, precedent. |
| **Staff+** | Peer review. Systemic impact, cross-team implications, design tradeoffs. Frame as discussion. |

Default: **Lead** if I skip.

## Step 3 — Deep Investigation

Spawn parallel agents driven by the lenses from Step 2. Each lens determines what its agent looks at and what prompt it gets. If multiple lenses share an agent type, prompt one agent with the union of concerns — do not spawn N copies.

### Agents

- **codebase-analyzer** — deep-read the changed files AND their callers/consumers. Map call chains, data flow, dependencies.
- **codebase-pattern-finder** — find how similar changes were made elsewhere. **Specifically check whether the codebase already has a utility, function, or module that does what new code is adding.** Duplication is a common review finding.
- **docs-researcher** — for new dependencies, APIs/libraries used in ways you're not 100% certain are correct, or framework patterns with version-specific behavior. Do NOT review library usage without checking the actual docs.

### Lens-specific prompting

Prompt each agent with the concerns implied by the active lenses:

- **Backend** → "Trace every database write for idempotency. Map transaction boundaries. Identify N+1 risks and missing indexes. Check job uniqueness configs."
- **Frontend** → "Audit interactive elements for ARIA and keyboard nav. Check for unnecessary re-renders. Verify design system token usage. Audit async-state coverage (loading/error/empty)."
- **Security** → "Trace every user input from entry through processing to storage and output. Verify auth checks at the data layer. Audit token exposure in logs, URLs, error messages."
- **Architecture** → "Map dependency directions between changed modules. Evaluate layering. Identify hidden coupling (shared mutable state, temporal coupling, implicit contracts)."
- **Ops** → "Audit observability for the new code paths. Verify config externalization. Identify unbounded resource consumption. Assess rollback paths and migration safety."
- **QA** → "Identify functions that lack unit tests despite branching logic. Flag tests that look vacuously passing. Audit mock/stub fidelity."
- **PM** → "Map every acceptance criterion to specific code changes. Flag missing requirements and out-of-scope changes."
- **Performance** → "Identify queries on large tables, hot-path computation, unbounded iteration. Verify index usage matches operator semantics."
- **Migration safety** → "Audit lock risk on large tables. Verify down-migrations. Check column types match domain semantics."
- **Dependency** → "Check new packages for maintenance status, license, and known security advisories. Identify what existing functionality, if any, this duplicates."

### Auto-escalate to dedicated skills

In parallel with the agents above, automatically invoke dedicated review skills for every matching trigger. **Do not ask.** Their findings get incorporated as subsections in Step 6's output ("Security Deep-Dive", "Architecture Assessment", "Performance Deep-Dive", "Requirements Traceability", "Quality Deep-Dive").

#### `/security-audit`
Auto-run when the diff touches ANY of:
- Authentication or authorization logic (auth, session, token, permission, policy)
- Input parsing or validation (params, body, query, headers, deserialization)
- Database queries constructed with user input
- File upload/download handling
- External API credential usage
- CORS, CSP, or security header configuration

#### `/my-arch-review`
Auto-run when the diff includes ANY of:
- New modules, services, or top-level directories
- Changes to module boundaries, public interfaces, or cross-module imports
- New dependency directions (module A now imports module B for the first time)
- Significant refactors that move code between layers or modules
- New infrastructure patterns (new queue consumers, new API gateways, new caching layers)

#### `/perf-review`
Auto-run when the diff touches ANY of:
- Database queries on known large tables or with missing/mismatched indexes
- Hot request paths (high-traffic endpoints, real-time features)
- Background job scheduling, concurrency, or queue configuration
- Caching logic (cache reads, writes, invalidation, TTL changes)
- Loops or iterations over potentially unbounded data sets
- Connection pool configuration or external service call patterns

#### `/requirements-audit`
Auto-run when ANY of:
- The PR links to a Linear ticket with detailed acceptance criteria (>3 criteria)
- The PR description references a spec, RFC, or design doc
- The change introduces new user-facing behavior (new endpoints, UI changes, notification logic)
- The PM lens is active
- Multiple requirements-related questions surface during the cursory pass

#### `/quality-audit`
Auto-run when ANY of:
- Tests are added or significantly modified in the PR
- New modules or services are added without corresponding test files
- Test assertions look vacuous (shape checks only, `assert true`, broad pattern matches)
- Mocks or stubs are used extensively — fidelity risk warrants dedicated analysis
- The QA lens is active
- The change touches high-risk code (payments, auth, data mutations) and test coverage looks thin

#### General triggers
Beyond the specific triggers above, also auto-run a relevant escalation when:
- The change is large enough (>500 lines, >10 files) that a single-pass review may miss systemic issues
- The lenses you triaged don't cover a concern you spotted (e.g. Backend lens active but you noticed auth changes → auto-run `/security-audit`)

### PR Mode constraints (pass into every agent and escalation prompt)

Research agents and escalation skills read the local filesystem by default and will silently read `main` (or whatever is checked out) instead of the PR's code:

> You are reviewing PR #<number>. You MUST NOT check out the PR branch, run `gh pr checkout`, `git checkout`, `git switch`, or `git fetch origin pull/N/head:<name>`. You MUST NOT treat the local working tree as the PR's code, and you MUST NOT compare against local `main` (it may be out of date with remote). For the PR diff, use `gh pr diff <number>`. For full file contents at PR HEAD, use `gh api repos/{owner}/{repo}/contents/{path}?ref=<sha>` where `<sha>` comes from `gh api repos/{owner}/{repo}/pulls/<number> --jq '.head.sha'`. For unchanged files (callers, consumers, conventions), the local working tree is fine — but any claim about a PR-modified file must come from the diff or `gh api`.

If an agent or escalation finding references a PR-modified file, verify the claim against the diff or `gh api` content before incorporating it.

## Step 4 — Targeted Questions

After deep investigation, surface specific concerns that need my context before you finalize. The point is to catch things where the situation depends on context only I have.

### Ask about

- **New architecture pattern** — first time this team/codebase is doing X. Is there an RFC or precedent? Should this set the precedent?
- **New ops pattern** — custom retry semantics, new alerting, new deploy gate, new infra dependency. Was this discussed with on-call?
- **New dependency** — what does it replace? Was maintenance / license / security vetting done? Is there an internal alternative?
- **Cross-team contract change** — new field, removed field, semantic change to an existing field. Has the consumer team been told?
- **Novel security surface** — first time exposing X publicly, accepting Y from a user, storing Z.
- **Ambiguous intent** — the PR description / ticket / docs left a question unresolved.

### Format

```
### Targeted Questions
1. <Concern in one phrase> — <one-line context from the investigation>
   <The specific question>
2. ...
```

### After I answer — challenge my answers

Once I respond, spawn the **adversarial-debate** agent to challenge *my* answers. This is a separate pass from the Step 7 finding challenge — the target here is my context, not the assistant's findings. Always run it when I've answered questions.

Pass to the agent:
- The original question + the investigation context that surfaced it (diff, relevant files, agent/escalation findings)
- My answer

The agent returns a verdict per answer:
- **ACCEPT** — answer holds up; move on
- **PROBE_FURTHER** — answer has gaps, unverified claims, or optimism bias; the agent supplies a follow-up question to ask me
- **FLAG** — answer reveals a real risk (e.g., "we didn't actually check that", "no, that team wasn't told") that should become a finding for Step 5

Apply the verdicts:
- ACCEPT → record the answer and proceed
- PROBE_FURTHER → ask me the follow-up question; re-run adversarial debate on the new answer (max 2 cycles, then accept or flag)
- FLAG → record as a structured finding for Step 5 (it will get its own adversarial pass in Step 7 along with every other finding)

### When to skip

If nothing surfaced, skip this step entirely. Do not manufacture questions to fill the section.

If I've authorized auto-mode (or said "no questions, just review"), log these as a **Questions** section in the final review output (Step 6) instead of pausing. The post-answer adversarial pass is also skipped in this mode — there are no answers to challenge.

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

### Security Deep-Dive
[Only if `/security-audit` was auto-run in Step 3 — skip otherwise]
[Findings from the dedicated security audit]

### Architecture Assessment
[Only if `/my-arch-review` was auto-run in Step 3 — skip otherwise]
[Findings from the dedicated architecture review]

### Performance Deep-Dive
[Only if `/perf-review` was auto-run in Step 3 — skip otherwise]
[Findings from the dedicated performance review]

### Quality Deep-Dive
[Only if `/quality-audit` was auto-run in Step 3 — skip otherwise]
[Findings from the dedicated quality audit]

### Requirements Traceability
[Only if a Linear ticket was linked OR `/requirements-audit` was auto-run — skip otherwise]
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

**Always** spawn the **adversarial-debate** agent to challenge every finding before presenting the review. Never skip this step — even on small diffs, even when findings look obvious. This is distinct from the Step 4 challenge (which targets *my* answers); this one targets *your* findings.

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

### Importance Filter — `/this-important`

After applying the adversarial-debate verdicts, run the surviving findings through `/this-important` to filter for importance before raising them. Correctness/verification is not the same as importance — a finding can be technically accurate but not worth the noise.

Invoke `/this-important strict` by default (override to `moderate` if QA, PM, or Architecture lenses are active, where more clarity/maintainability findings are warranted; override to `loose` only if I explicitly ask for a thorough sweep).

Pass the full set of blocking issues, non-blocking suggestions, and questions as the target findings. Apply the returned verdicts:

- **KEEP** → present as-is in the chosen severity tier
- **DOWNGRADE** → move from blocking to non-blocking, or from finding to question
- **DEFER** → move to a follow-up note rather than a review comment
- **DROP** → remove entirely and add a one-line entry to "Dropped Findings" with the reason

The point: every issue raised should clear an explicit importance bar. Reviewers should not have to wade through noise to find the items that matter.

### Post-Challenge Checklist

After applying verdicts, confirm:
- [ ] Blocking vs. non-blocking classification reflects the agent's severity calibration
- [ ] Every surviving finding passed the `/this-important` filter
- [ ] Dependency docs were checked for any non-obvious API usage
- [ ] No comment duplicates anything already raised in existing review threads
- [ ] Findings are grounded in the codebase research from Step 3, not assumptions
- [ ] Dropped Findings section captures what `/this-important` filtered out, with reasons

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
