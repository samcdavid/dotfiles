# Review Categories — Rubric

Used by Step 3 of `/create-pr`. These are guidance for the sequential-thinking analysis — not rigid regex matchers. Reason from the diff and commit messages using these as a checklist.

## RISC Scoring

For the change overall, estimate four components on a 1–10 scale:

- **Reach** — How much code does this touch? 1 = single function. 10 = cross-cutting (touches many modules / apps / interfaces).
- **Irreversibility** — How hard to undo? 1 = trivial revert with no side effects. 10 = data migration, schema change, or an irrecoverable state transition.
- **Subtlety** — How easy to misunderstand? 1 = obvious mechanical change. 10 = hidden invariant, race condition, async/sync coupling, or domain logic that won't look wrong on first reading.
- **Consequence** — What breaks if this is wrong? 1 = cosmetic. 10 = data loss, security incident, billing impact, or production outage.

### Verdict thresholds

- Any component **≥9** → **High** verdict. Render the Risk Assessment block. Surface every component ≥7 in the body.
- Any component **≥7** → **Medium** verdict. Render the Risk Assessment block. Surface every component ≥7 in the body.
- Otherwise → **Low** verdict. Omit the Risk Assessment block entirely.

### Signals that typically drive each component high

**Reach ≥7**
- Touches multiple top-level apps or services simultaneously
- Changes a shared library used by many consumers
- Refactor that moves code across module boundaries

**Irreversibility ≥7**
- Database migrations or schema changes (any framework)
- Changes to data serialization formats persisted in storage, queues, or caches
- New background job types where in-flight jobs would be stranded by a revert
- Public API contract changes (OpenAPI, GraphQL, RPC, webhook payloads)
- New third-party service integrations (revert leaves dangling external state)

**Subtlety ≥7**
- Idempotency, ordering, timing, or retry semantics in async/job code
- Auth / session / token / permission / policy code
- LLM prompts, system messages, or tool docstrings (behavioral drift hard to spot in review)
- Changes to caching invariants

**Consequence ≥7**
- Auth / authn / authz changes
- Anything affecting billing, payments, or compliance surfaces
- Background job changes that could duplicate user-visible work
- Migration on a large table where lock duration matters

When in doubt: if a rollback would require coordinating with anyone outside the author, at least one component is probably ≥7.

## Primary Lens Recommendation

| Signal in the diff | Primary Lens |
|---|---|
| Server-side code only (business logic, queries, jobs, services) | Backend |
| Client-side code only (components, styles, client state) | Frontend |
| Both, with non-trivial work on each side | Full-stack — call out the seam in Focus Areas |
| Test files dominate (>50% of changed files are tests) | Quality |
| User-facing behavior with explicit acceptance criteria in the linked ticket | PM |
| Deployment, observability, config externalization, runtime/ops surfaces | Ops |
| Module boundaries / new dependency directions / new top-level structure | Architect |
| Auth / session / token / permission / policy code | Security (as primary, not just triggered, when auth IS the change) |

Lens vocabulary matches `/my-review` lenses so the PR routes cleanly to that skill.

**Picking among multiple candidates:** primary lens lives where the riskiest reasoning lives. Add a Secondary lens only when both sides of the PR carry non-trivial work in different lenses.

## Specialty Review Triggers

Multiple triggers can fire on the same PR. Be specific in the PR body about which files set off which trigger.

| Trigger signal | Specialty Review |
|---|---|
| Auth / session / token / permission / policy code modified | `/security-review` |
| Input parsing, validation, or deserialization at a system boundary | `/security-review` |
| File upload/download handling | `/security-review` |
| External API credentials, CORS, CSP, or security headers | `/security-review` |
| Public API contract changes (OpenAPI, GraphQL, webhooks, channels, RPC) | Doc alignment check + flag for manual review |
| New top-level module or new dependency direction between modules | `/my-arch-review` |
| Significant refactor moving code between layers or modules | `/my-arch-review` |
| DB migration, schema change, index change, NOT NULL add on a potentially-large table | `/perf-review` + ops attention |
| Queries on known large/hot tables, or in hot request paths | `/perf-review` |
| Caching read/write/invalidation logic | `/perf-review` |
| Loops or iterations over potentially unbounded data sets | `/perf-review` |
| LLM prompts, system messages, or tool docstrings modified | Verify eval coverage exists before merge |

## Focus Areas — what to call out

Up to 5 entries. Prefer places where:

- Business-logic intent matters more than code correctness (a reviewer skill catches the latter)
- The diff is large or dense and a human needs to know where to start
- The change crosses a boundary (cross-service contract, cross-module dependency)
- Edge cases or error paths exist that aren't covered by tests
- A subtle invariant could break (idempotency, ordering, timing, retry semantics)
- A magic value, threshold, or constant deserves a second pair of eyes

Don't pad to fill the cap. Three sharp focus areas beat five vague ones.

## Documentation Alignment

Include only when integration points changed. Examples:

- OpenAPI / GraphQL schema diff → consumer docs, SDK README
- Webhook payload change → external integration partner docs
- New environment variable or runtime config → runbook, onboarding doc, `.env.example`
- New CLI flag or command → `--help` output, README, internal docs
- New public function signature → in-code docs, design docs that reference it

Skip this subsection entirely if nothing integration-shaped moved. Empty doc sections train reviewers to skim past.
