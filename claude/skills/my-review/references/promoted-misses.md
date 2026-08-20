# Learned Misses — promoted/discarded archive

Audit trail for `references/learned-misses.md`'s pattern queue: entries that crossed the promotion threshold (or were explicitly discarded) move here, in the same schema, and are never deleted. See `learned-misses.md`'s `## Schema` section for field definitions and `SKILL.md` § "Queue lifecycle and auto-promotion" for the lifecycle rules.

When checking whether a new capture matches an existing Shape, check this file in addition to `learned-misses.md`'s `## Pending`. A match here means the pattern is already codified in its target file — append new Evidence to the entry here (useful signal on whether the promoted rule is actually catching recurrences) rather than creating a fresh pending duplicate.

## Promoted

<!-- Entries with status: promoted (preserved for audit, never deleted automatically). -->

### A prose claim about the live system (schema, ADR, query plan) is accepted without checking it against the real thing

- **Shape** — A comment, docstring, or PR-body sentence asserts a fact about the live system — a DB column has no NOT NULL constraint, an ADR requirement is satisfied or doesn't apply here, an index choice is justified by the query's selectivity, or "this fix handles the real input" — and the claim is accepted as true because it reads plausibly, not because anyone checked it against the actual schema, ADR text, query plan, or real production-shaped data.
- **Trigger signals** — a docstring/comment/PR description asserts a schema fact (nullability, constraint, uniqueness) with no migration or schema dump in the diff to verify it against; an ADR is cited as the basis for a decision without quoting or checking its actual text; an index/query justification cites selectivity or access-pattern behavior with no `EXPLAIN`/query-plan check; a parsing or data-extraction fix claims correctness based on a synthetic/example input rather than the real production-shaped data it's meant to handle.
- **Evidence**
  - `- {type: missed, ref: PR #27568, date: 2026-08-05}` — a docstring claimed "no NOT NULL constraint" when 6 of 15 DB columns actually are NOT NULL; caught on external re-review, not the original pass.
  - `- {type: missed, ref: PR #27518, date: 2026-08-05}` — an ADR-required field-equality check was waved off as deferred; the ADR's actual text mandates it.
  - `- {type: missed, ref: PR #27736, date: 2026-08-05}` — a GIN-index justification had the selectivity backwards versus the real query plan.
  - `- {type: missed, ref: PR #27632, date: 2026-08-05}` — a table-extraction fix passed CI and bot review but failed when the real article was run through the real pipeline, three review rounds in a row.
- **Proposed promotion** — `target: references/general-checklist.md` (Correctness / Bugs); `wording:` "Claim verification — a comment, docstring, or PR-body sentence asserting a fact about the live system is a claim, not evidence. Check it against the actual source (real schema/migration, ADR text, query plan, or real production-shaped input) — a plausible-sounding prose justification that doesn't survive this check is a Critical finding, not a nit."
- **Status** — promoted (2026-08-05)

### Cross-service contract review checks shape alignment but not the consumer's actual handling of a malformed/duplicate value

- **Shape** — Reviewing a cross-service change by comparing schemas/shapes on both sides misses defects that only appear when a malformed, duplicate, or unexpected-but-valid value actually reaches the consuming service — those require reading the *consumer's* handling code, not just checking that field names/types look aligned.
- **Trigger signals** — a PR sends a field, ID, or enum value across a service boundary; the review checks producer/consumer schema shape but doesn't trace what the consumer's code does with a duplicate, out-of-vocabulary, or edge-case value; a bulk/relational write (`insert_all`, upsert) is claimed to preserve associated records without checking against the specific bulk operation's actual behavior; a fix is framed as satisfying a ticket's correctness definition without checking every predicate in that definition.
- **Evidence**
  - `- {type: missed, ref: PR #26218, date: 2026-08-05}` — duplicate IDs in an Astro-side list crashed Axon with an opaque 500 instead of a clean validation error.
  - `- {type: missed, ref: PR #25361, date: 2026-08-05}` — a screener `question_type` didn't round-trip to the API vocab.
  - `- {type: missed, ref: PR #27398, date: 2026-08-05}` — `insert_all` silently dropped `has_many` changes, so a closed card sort persisted with zero cards.
  - `- {type: missed, ref: PR #27467, date: 2026-08-05}` — a resolver fix stopped one predicate short of the ticket's own correctness definition, verified against production data.
- **Proposed promotion** — `target: references/cross-service-contracts.md` (new "Failure-Path Tracing" section); `wording:` "Trace what the consuming service actually does with a duplicate/out-of-vocabulary/boundary value, verify round-trips against the consumer's real parsing code (not schema comparison alone), verify bulk writes actually preserve associations for the specific operation used, and check a fix against a ticket's full correctness definition, not just its first predicate."
- **Status** — promoted (2026-08-05)

### A deferral cites a ticket number without confirming the ticket exists or covers the gap

- **Shape** — A reviewer or author defers an issue "to TICKET-X" and the deferral is accepted because a ticket number is present, without fetching the ticket to confirm it exists and that its actual description covers the specific gap being deferred — not just a topically-adjacent concern.
- **Trigger signals** — a review comment, PR description, or fix response defers a finding to a cited Linear ticket; the ticket isn't fetched and its text isn't checked against the specific gap; a deferral (`tach-ignore`, `# TODO`, "out of scope") has no ticket at all while sibling deferrals in the same PR do; a dependency-version deferral treats a security advisory as closed based on a stale target version.
- **Evidence**
  - `- {type: missed, ref: PR #27606, date: 2026-08-05}` — a RecursionError was deferred to two Linear tickets that never mention recursion.
  - `- {type: missed, ref: PR #27679, date: 2026-08-05}` — a `tach-ignore` deferral had no ticket at all while every sibling deferral in the PR did.
  - `- {type: missed, ref: PR #27713, date: 2026-08-05}` — stale dependency version targets left security advisories open that the PR read as closed.
- **Proposed promotion** — `target: requirements-audit/references/protocol.md` (Gap Analysis, new "Deferral Verification" subsection) and `~/.claude/agents/skill-address-pr-feedback/references/protocol.md` (Valid Deferral classification); `wording:` "A deferral is only valid if the cited ticket is fetched, confirmed to exist, and confirmed to cover the specific gap by its actual text — not inferred from the ticket ID or title alone. No ticket, a nonexistent ticket, or a non-covering ticket means the item is genuinely missing, not deferred."
- **Status** — promoted (2026-08-05)

### A new guard/test that only exercises the current-good state doesn't prove it catches the drift it claims to

- **Shape** — A new test or guard is added specifically to catch a category of drift (a schema/contract check, an invariant assertion, an inventory-completeness check) but review accepts it by reading what it checks, not by confirming it actually fails when the specific defect it's meant to catch is reintroduced.
- **Trigger signals** — a new contract/schema-diff check enumerates fields explicitly (blind to `default_factory`, inheritance, or dynamic fields); an "inventory is complete" or "all X have Y" check only verifies one direction; a new regex-based guard isn't anchored (`^`/`$`, word boundaries); a new test snapshots or diffs human-readable prose (docs, error messages) rather than the underlying behavior.
- **Evidence**
  - `- {type: missed, ref: PR #27568, date: 2026-08-05}` — a dataclass-field contract check was blind to fields added via `default_factory`.
  - `- {type: missed, ref: PR #27679, date: 2026-08-05}` — a one-directional "inventory is complete" check missed drift from the unchecked direction.
  - `- {type: missed, ref: PR #27680, date: 2026-08-05}` — a prose-snapshot test broke on doc rewording rather than catching a real defect.
- **Proposed promotion** — `target: quality-audit/references/protocol.md` (Step 5, new "Mutation Check for New Guards" subsection); `wording:` "For any new guard whose purpose is to catch a specific drift category, reintroduce the exact defect it claims to catch (mentally or actually) and confirm it fails — reading what a guard checks is not the same as confirming it catches the failure. Named blind spots: field enumeration blind to `default_factory`/dynamic fields, one-directional completeness checks, unanchored regexes, prose-snapshot tests that break on rewording instead of real defects."
- **Status** — promoted (2026-08-05)

### New telemetry (metric/index/log field) is emitted correctly but the underlying value is degenerate, so it produces no usable data

- **Shape** — A new metric, DB index, or log field is emitted at the right call site with the right names/labels, so a structural review ("is it emitted, do the labels match") passes — but the actual *value* being emitted is degenerate: hardcoded to a constant, sourced from a field never populated on the exercised code path, or relying on metric-type semantics (e.g. gauge stickiness) the backend doesn't actually provide.
- **Trigger signals** — a new DB index or filtered query targets a field; a new counter/gauge/histogram is added for a Datadog/StatsD-style backend; the field or metric source traces back to a hardcoded default or a rarely-true condition; the plan assumes a metric type behaves a specific way (sticky gauge, monotonic counter) without checking the specific backend's actual semantics.
- **Evidence**
  - `- {type: missed, ref: PR #25896, date: 2026-08-05}` — a DB index built for `study_id` stayed permanently empty because the field was hardcoded `None`.
  - `- {type: missed, ref: PR #27664, date: 2026-08-05}` — two of five new Datadog metrics wouldn't produce a readable series because a DogStatsD gauge isn't sticky.
- **Proposed promotion** — `target: references/general-checklist.md` (Observability subsection) and `~/.claude/agents/skill-my-validate/references/protocol.md` (Observability Validation Step 2); `wording:` "Trace the actual value behind new telemetry, not just its call site — a hardcoded/rarely-populated field makes an index or metric permanently empty even when the emission code is correct, and a metric type's assumed semantics must be checked against the specific backend, not assumed."
- **Status** — promoted (2026-08-05) — below the normal len(evidence)>=3 auto-promote threshold; promoted manually on the strength of an independent cross-team root-cause investigation (Colin Campbell, DEVENVT-39) rather than accrued evidence. Treat further recurrences as Evidence appended here, same as any other promoted entry.

### Foundational/greenfield code with no current consumers gets a lighter review pass because "nothing depends on it yet"

- **Shape** — A PR introduces new foundational or greenfield code (a new DSL, semantic model, or composition primitive) with zero current callers. Review treats the low blast radius as a reason to soften scrutiny, when zero consumers is actually the cheapest possible moment to fix a bug — before anything depends on the wrong behavior.
- **Trigger signals** — a PR adds a new DSL, semantic model, schema, or composition primitive with no call sites yet in the diff or the wider codebase; review commentary frames a finding as lower-priority because "nothing uses this yet" or "no consumers currently."
- **Evidence**
  - `- {type: missed, ref: PR #27526, date: 2026-08-05}` — confirmed defects in new DSL/semantic-model and Strata composition-primitive code, both in code with no consumers yet — cheap to fix now, framed by the external reviewer as exactly why it should have been caught immediately rather than deferred.
- **Proposed promotion** — `target: references/general-checklist.md` (Blast Radius); `wording:` "Zero-consumer code is not lower-risk — new foundational/greenfield code still gets full correctness scrutiny; 'nothing depends on it yet' is a reason bugs are cheap to fix now, not a reason to soften the review."
- **Status** — promoted (2026-08-05) — below the normal len(evidence)>=3 auto-promote threshold; promoted manually on the strength of an independent cross-team root-cause investigation (Colin Campbell, DEVENVT-39) rather than accrued evidence. Treat further recurrences as Evidence appended here, same as any other promoted entry.

## Discarded

<!-- Entries with status: discarded (preserved for audit, never deleted automatically). -->
