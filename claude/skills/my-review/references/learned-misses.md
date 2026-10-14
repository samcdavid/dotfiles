# Learned Misses — pattern queue

Patterns the skill should learn to catch (or has caught and confirmed are recurring). Entries accumulate Evidence over time. When `len(evidence) >= 3`, an entry is auto-promoted into the relevant lens reference or `gotchas.md`.

See `SKILL.md` § "Queue lifecycle and auto-promotion" for rules. Promoted and discarded entries live in `references/promoted-misses.md`, not here — this file holds only the active `## Pending` queue, split out to stay under the reference word-budget cap. Keep entries terse: one or two sentences per field, evidence reduced to the ref, the `file:line`, and the decisive fact.

## Schema

Each entry is a markdown subsection with:

- **Shape** — the general pattern (the load-bearing field; matching new captures against existing Shapes appends Evidence rather than creating duplicates)
- **Trigger signals** — what in a diff should make the skill stop and check this pattern
- **Evidence** — list of `- {type: caught|missed|noted, ref: <pr#/comment-link/session>, date: YYYY-MM-DD}` entries
- **Proposed promotion** — optional at capture; `target: <file>` + draft `wording:` (required for hard auto-promote — otherwise target is inferred and wording is generated)
- **Status** — `pending` | `ready` | `promoted (YYYY-MM-DD)` | `discarded (YYYY-MM-DD, reason)`

## Pending

<!-- Entries with status: pending or ready live here. Order: most recently updated first. -->

### An eval row added as evidence for an LLM-docstring change can't reach the scored decision

- **Shape** — An eval row offered as coverage for prompt/docstring wording can't reach the decision it targets (the harness forces an earlier call, or the row lacks seeded turns), so it scores something else regardless of the wording.
- **Trigger signals** — a dataset row added to resolve a review thread; a `first_tool` expectation that isn't the harness's forced first call; no `history` when sibling rows use one; offline-only evals.
- **Evidence**
  - `- {type: caught, ref: PR #30064, date: 2026-10-14}` — row `invited_never_submitted_participants` expected `list_entries(view="participants")` first with no `history`, but `server.py:235` forces `list_accounts` first and `eval_tool_selection.py:55-62` requires a seeded row; I approved on it before catching this.
- **Proposed promotion** — `target: references/general-checklist.md` (QA); `wording:` "When an eval row or test is offered as coverage for prompt/docstring wording, check the harness can actually reach the scored decision — forced earlier calls (discovery, auth) or missing seeded turns mean the row scores something else regardless of the wording."
- **Status** — pending

### A new parameter reuses a name existing tool prose already uses for something else

- **Shape** — A tool gains a parameter named like a field its docstring already tells the agent to handle differently, so the old sentence now reads as an instruction to pass the new parameter where it's refused or means something else.
- **Trigger signals** — a new parameter on an LLM-facing tool; the same identifier in backticks elsewhere in the docstring; the parameter only works in one mode/view.
- **Evidence**
  - `- {type: caught, ref: PR #30064, date: 2026-10-14}` — `list_entries` gained `status` (participants view only) while `tools/data_access.py:540` still said "Filter on `status` yourself".
- **Proposed promotion** — `target: references/general-checklist.md`; `wording:` "When an LLM-facing tool gains a parameter, grep its docstring for the same identifier used in another sense — an old sentence about a row field or concept now reads as an instruction to pass the new parameter."
- **Status** — pending

### A comment's stated reason holds for only some of the code paths it covers

- **Shape** — A comment justifies a choice with a property (freshness, boundedness, atomicity) that some of the dispatch paths it covers don't have, misleading the next reader even when the choice is right.
- **Trigger signals** — "must show up / always current / bounded / atomic" above code that dispatches by product or type; a branch that reads a cache or loads a full set before paging.
- **Evidence**
  - `- {type: caught, ref: PR #30064, date: 2026-10-14}` — `participant_controller.ex:26-27` claimed a bounded, fresh primary read; Diary/Interviews read the `Axon.Stats` Redis cache and load the whole member set first.
- **Proposed promotion** — `target: references/general-checklist.md` (Clarity for Future Readers); `wording:` "When a comment justifies a choice with a property (freshness, boundedness, atomicity), check that property holds on every branch the comment covers — a cache- or full-load-backed branch makes the stated why false even when the choice is right."
- **Status** — pending

### A new guard re-loads records the caller already holds

- **Shape** — A new guard in a request pipeline re-fetches records the caller already loaded, adding per-request queries, and a raising fetch (`Repo.get!`) turns a missing row into a 500 instead of the promised validation error.
- **Trigger signals** — `Repo.get!`/`Repo.preload` in a function returning `:ok | {:error, ...}`; a guard given an id when callers hold the record; one guard threaded into several entry points.
- **Evidence**
  - `- {type: missed, ref: PR #30044 (gardoroman review, 2026-10-14), date: 2026-10-14}` — `DemographicFilters.guard/3` re-ran `Repo.get!(Account, ...)` plus license and `arm_screener` preloads per request; my two earlier approvals missed it.
- **Proposed promotion** — `target: references/lenses/performance.md`; `wording:` "For a new guard/validator in a request pipeline, check whether it re-fetches records callers already hold, and whether a raising fetch (`get!`) breaks its `:ok | {:error, _}` contract — pass the loaded record instead."
- **Status** — pending

### Privacy or safety prose overstates what the code guarantees

- **Shape** — Docs or tool descriptions state an absolute privacy guarantee that holds only narrowly while another channel (ids, membership, repeated narrowing) still discloses the data; agents and reviewers act on the stated guarantee.
- **Trigger signals** — "no / never / only" about participant data in docs or tool descriptions; a guarantee resting on response shape while ids are still returned.
- **Evidence**
  - `- {type: missed, ref: PR #30044 (gardoroman review, 2026-10-14), date: 2026-10-14}` — docs said "no response carries a participant's demographic values", but rows carry `participant_id`, so filter membership discloses each value.
- **Proposed promotion** — `target: references/lenses/security.md`; `wording:` "Check absolute privacy claims in docs and tool descriptions against every disclosure channel (membership, ids, repeated queries), not just response fields; reword claims that hold only in a narrow case."
- **Status** — pending

### A cross-language vocabulary kept in step only by a comment

- **Shape** — A closed value set is defined on both sides of a service boundary with only a "keep in step" comment and no test comparing them, so drift fails silently. (Distinct from the "mirror vs current upstream" entry, which is staleness at merge time.)
- **Trigger signals** — a "keep in step with / must match" comment; the same literal list in two languages; no test reading both.
- **Evidence**
  - `- {type: missed, ref: PR #30044 (gardoroman review, 2026-10-14), date: 2026-10-14}` — age bands duplicated in Astro `schemas/filter.py` and Axon `DemographicFilters`; gardoroman asked for a parity test, I didn't.
  - `- {type: caught, ref: PR #30064, date: 2026-10-14}` — `schemas/metrics.py:16-19` lockstep comment still named `Domain.MCP.ParticipantStatusCounts` after the lists moved to `Domain.MCP.ParticipantUniverse`.
- **Proposed promotion** — `target: references/cross-service-contracts.md`; `wording:` "When a closed vocabulary is duplicated across a service boundary, require a test that compares both definitions (or a single generated source) — a 'keep in step' comment is not enforcement."
- **Status** — pending

### A "never logged" privacy claim verified against only one telemetry sink

- **Shape** — A "sensitive values are never logged" claim is checked only against the sink the diff touches, while other sinks (Braintrust spans, LLM traces, error trackers) redact by registration or allowlist and log unregistered tools in full.
- **Trigger signals** — a "never logged / field names only" claim or AC; a new sensitive input on an existing tool; redaction keyed on tool registration; an AC marked "Covered" after checking one sink.
- **Evidence**
  - `- {type: caught, ref: PR #30044, date: 2026-10-14}` — `compute_study_metric` is unregistered, so Astro `_telemetry._safe_input` logged `filters[].value` (gender, minor age bands) to Braintrust; a bot had marked the AC "Covered" from Datadog tags alone.
- **Proposed promotion** — `target: references/lenses/security.md`; `wording:` "When a PR or AC claims sensitive values are never logged, enumerate every telemetry sink the touched code path reaches (OTel/Datadog attributes, Braintrust span input/output, LLM trace capture, error trackers) and verify each one's redaction rule for this specific tool — registry- or allowlist-keyed redaction silently skips unregistered tools."
- **Status** — pending

### Narrowing a shared schema by subclassing replaces its LLM-facing docstring

- **Shape** — Subclassing a schema model to hide fields from one LLM agent makes the subclass docstring that agent's description, silently dropping guidance the parent carried; the narrowing is tested, the lost guidance isn't.
- **Trigger signals** — a new subclass of a model in an LLM tool `args_schema`/`bind_tools`; `json_schema_extra` pruning enums; a subclass docstring shorter than the parent's.
- **Evidence**
  - `- {type: caught, ref: PR #30044, date: 2026-10-14}` — `CrossMissionFilterCondition(FilterCondition)` dropped the parent's id-provenance guidance and "substring matching on choice labels does not exist"; tests checked only the enum.
- **Proposed promotion** — `target: references/general-checklist.md`; `wording:` "When a schema model used by an LLM tool is subclassed to narrow it, diff the subclass docstring against the parent's — the subclass's becomes the agent-visible description, so guidance not restated is silently removed."
- **Status** — pending

### "Parity with the app" offered as justification without checking the app's actual gate

- **Shape** — A PR justifies refusals or permissions as "parity with the app" when the app's real gate differs; the code may be fine (often stricter) but decisions get made on a false rationale.
- **Trigger signals** — prose claiming the same scope as a frontend surface; a list of flags/roles "mirroring the app" with no frontend gate cited; sign-off framed as parity.
- **Evidence**
  - `- {type: caught, ref: PR #30044, date: 2026-10-14}` — filters refused on BYO, private panel, and five pii-* flags "where Dendra hides these"; Dendra's gate is `recruit && !isBYOSScreener(recruit)` and reads no pii-* flags.
- **Proposed promotion** — `target: references/lenses/requirements.md`; `wording:` "When a PR justifies behavior as parity with the app, find the app's actual gate (feature evaluator, permission check) and compare it — a parity claim reviewers approve on must match the real condition, or be restated as deliberately stricter/looser."
- **Status** — pending

### A cross-app UI port leaves locale-sensitive formatting unpinned, diverging from the source's actual fixed-locale behavior

- **Shape** — A port of UI formatting leaves `toLocale*`/`Intl.*` on the browser's default locale while the source renders a fixed format, even under a comment claiming parity; it only shows for non-English users.
- **Trigger signals** — a port claiming format parity; `toLocaleDateString`/`toLocaleTimeString`/`Intl.DateTimeFormat` with `undefined` or no locale; a source library capable of both fixed and locale-aware output (e.g. moment tokens).
- **Evidence**
  - `- {type: missed, ref: PR #27420, date: 2026-07-28}` — `VisitPathMissionItem.tsx` used the default locale; Dendra formats with fixed moment tokens (`'MMM D, YYYY'`/`'h:mm A'`). A teammate caught it; fixed by pinning `"en-US"`.
- **Proposed promotion** — `target: references/general-checklist.md` (beside the "mirror must be verified against current upstream" entry); `wording:` "When a PR ports/mirrors formatting behavior from another codebase, check that locale-sensitive calls (`toLocaleDateString`/`toLocaleTimeString`/`Intl.*`) are pinned to match the source's actual locale behavior. A comment claiming parity is not evidence — check the source's real formatting mechanism (fixed vs. locale-aware tokens)."
- **Status** — pending

### Code comments narrate review/process provenance instead of stating the durable invariant

- **Shape** — Comments narrate review or process history ("verified on staging", "per earlier pass", inline ticket narrative) instead of the durable why, and become noise once the thread is gone. A bot catches this reliably; this skill never has, so it needs an affirmative check.
- **Trigger signals** — a new comment mentioning "staging", "verified on", "earlier pass", "review", "historical", or an inline ticket id in prose.
- **Evidence**
  - `- {type: noted, ref: PR #27420, date: 2026-07-28}` — baz-reviewer flagged four in `JourneyPanel.tsx`, `useJourneyClicksData.ts`, `interceptUrlQuery.ts`, `useClickTrackingPlaybackSync.ts`; fixed in `49d4468`, `d6d90c4`.
  - `- {type: noted, ref: PR #27768, date: 2026-08-06}` — same bot, another author: 4 of 7 threads (`FRG-800` refs in tests, `_refuse_governed_override` docstring, `CreateMissionForm.tsx`); `my-review` surfaced none.
- **Proposed promotion** — `target: references/general-checklist.md` (Clarity for Future Readers); `wording:` "Flag code comments that narrate review/process provenance (staging verification, 'per earlier pass', inline ticket references, review-history framing) instead of stating the durable invariant or rationale. A comment should state WHY the code works this way, not HOW it came to be reviewed or verified."
- **Status** — pending

### A new LLM feature/agent rebuilds platform LLM plumbing instead of using the sanctioned mechanism

- **Shape** — A new LLM feature re-implements plumbing the platform already standardizes: literal prompt strings instead of the versioned prompt registry, hand-rolled provider tool dicts and direct SDK calls instead of the sanctioned tool framework, or a local PII regex instead of the shared primitive. Also flag module names that collide with a shared concept.
- **Trigger signals** — a literal system prompt with no slug/version; `TOOL_DEFINITIONS`/`TOOL_HANDLERS` dicts with direct `anthropic`/`openai` calls; a local `pii`/`redact`/`guardrail` module; deps missing the `[llm]`/`[prompts]` extras siblings use. Siblings (astro, ai_mod) use `fastmcp-slim`/LangChain, `dscout_core_py.llm.BraintrustPrompt`, and `dscout_core_py.observability.pii_masking`.
- **Evidence**
  - `- {type: missed, ref: PR #25914, date: 2026-06-02}` — approved a support-agent service with a hard-coded `system_prompt.py`, hand-rolled tools plus direct SDK calls, a third copy of the PII regexes in `guardrails/content.py`, and a "guardrails" name collision; the user raised all four.
- **Proposed promotion** — `target: references/general-checklist.md` (LLM-plumbing conformance); `wording:` "For a PR that adds/changes an LLM feature or agent, check it uses the platform's sanctioned plumbing: prompts via the hosted/versioned registry, tools via the established framework (fastmcp/MCP or LangChain), PII/content-safety via the shared core primitive. Flag module-name collisions with shared concepts. Correct, self-consistent LLM code can still establish a divergent convention and skip prompt/eval governance."
- **Status** — pending

### A flag-gated / lazily-loaded data source feeding a non-gated consumer fails open

- **Shape** — A restrictive affordance (lock, gate, hide) reads data that only a flag-gated or lazy fetch loads; when the consumer is reachable without that condition, absent data falls to the permissive branch and the restriction silently doesn't apply.
- **Trigger signals** — a lock/gate decision reading a store filled only by a conditional fetch; a consumer reachable outside that condition; "absent" and "permissive" on the same branch; no fail-closed default.
- **Evidence**
  - `- {type: caught, ref: PR #26006, date: 2026-06-02}` — an export-modal field lock read a store filled only by a feature-flagged fetch while the modal wasn't gated; with the flag off it failed open.
- **Proposed promotion** — `target: references/general-checklist.md` (data integrity); `wording:` "A restrictive UI affordance (lock/gate/hide/disable) derived from conditionally-loaded data must fail closed or distinguish 'unresolved' from 'empty' — trace the sole loader's gating against every path that reaches the consumer."
- **Status** — pending

### Acceptance-criterion behavior ships in untested glue while tests cluster on an adjacent layer

- **Shape** — The acceptance criterion lives in glue (prop threading, conditional render, prompt rendering) while thorough tests cover an adjacent layer, masking that the criterion itself is never asserted.
- **Trigger signals** — a linked ticket with a concrete AC; new tests concentrated on a store/reducer/util; the AC marked "met" from reading code rather than a test.
- **Evidence**
  - `- {type: caught, ref: PR #26006, date: 2026-06-02}` — store-layer tests were thorough, but nothing asserted the field locking and pre-populating; that lived in untested modal glue.
  - `- {type: caught, ref: PR #26281, date: 2026-06-11}` — FRG-862 AC#1 (supervisor doesn't ask to confirm criteria) lived in untested prompt-render glue that still rendered "Does this look correct?".
- **Proposed promotion** — `target: references/general-checklist.md` (QA / requirements coverage); `wording:` "When a PR links a ticket with a concrete acceptance criterion, check that a test asserts the criterion's end-to-end behavior, not just an adjacent sub-layer. 'Code looks right' ≠ 'criterion is asserted'."
- **Status** — pending

### Cross-service mapper bug masked by a test fixture richer than the real client's wire shape

- **Shape** — The consumer's tests hand-build a richer payload than the producer's mapper actually emits, so they pass while the live cross-service path drops or corrupts data.
- **Trigger signals** — an endpoint fed by another service's serializer; consumer tests with hand-built input; the producer emits `list[str]` or omits a field the consumer reads; round-trip asserted only at the producer.
- **Evidence**
  - `- {type: caught, ref: MCP-265 session, date: 2026-06-10}` — `_build_payload_from_plan` omitted question `position`; Axon defaulted all to 0 and misclassified `child_blocks`. Axon tests supplied `position: 1/2`.
  - `- {type: caught, ref: MCP-265 session, date: 2026-06-10}` — `ProposedScreenerQuestion.choices: list[str]`, but `map_single_screener_question` does `Map.get(c, "label")` → nil labels. Tests supplied label maps.
- **Proposed promotion** — `target: references/cross-service-contracts.md`; `wording:` "For an endpoint fed by another service's serializer, verify the consumer's expected shapes against the producer's actual emitted shape, not the consumer's fixtures. Require one integration test that drives the real wire shape through the full HTTP/translation path."
- **Status** — pending

### Event-emit path is executed by existing tests but the fire/silent/payload decision is never asserted

- **Shape** — A new conditional emit runs inside already-tested code and shows as covered, but no test asserts whether it fired, how often, or with what payload.
- **Trigger signals** — a diff-, threshold-, or dedupe-gated emit; an unmocked, injectable dispatcher; assertions only on resulting state.
- **Evidence**
  - `- {type: caught, ref: PR #26006, date: 2026-06-02}` — a diff-gated emit ran in tests that asserted only state; fire-once and silent-on-no-change were never checked.
- **Proposed promotion** — `target: references/general-checklist.md` (QA / test fidelity); `wording:` "For a newly-added conditional emit, check that a test asserts the emit decision — fired vs. not, fire-count, and payload — not just resulting state."
- **Status** — pending

### A "mirror"/"ported" constant or formula must be verified against the CURRENT upstream, not the PR's base

- **Shape** — A mirrored formula, schema, or constant is checked against the source at the PR's base rather than the current default branch, so parity true at branch time ships stale.
- **Trigger signals** — "mirrors / matches / ports / keeps in sync with" in the PR; the source isn't in the diff; the source has commits after the branch base; another reviewer "verified term-by-term".
- **Evidence**
  - `- {type: caught, ref: PR #25998, date: 2026-06-02}` — a backend port matched the frontend formula at the base, but upstream had been re-tuned since (~2–3.6× off plus a dropped term); caught by reading the upstream file at the default branch.
- **Proposed promotion** — `target: references/cross-service-contracts.md`; `wording:` "When a change mirrors/ports a value from another file or service, verify it against that source at the current remote default-branch ref, not the PR's base, and scan its recent history. Parity at branch time doesn't prove parity at merge time."
- **Status** — pending

### Entity-level flag derived per-sublist when the same function runs on partitions of one set

- **Shape** — A function derives an entity-level flag from the collection it's given (`any(...)`) and is called on partitions of one set, so the flag can flip between partitions; compute it once over the full set.
- **Trigger signals** — `any()`/`some()`/`exists?` over a parameter; the same function called on complete/incomplete, paged, or filtered subsets; marker items that can all land in one partition.
- **Evidence**
  - `- {type: caught, ref: PR #25998, date: 2026-06-02}` — an effort function derived an entity-type flag per list; once marker items were consumed, the incomplete list mis-priced the remainder. Fixed via the existing override param.
- **Proposed promotion** — `target: references/general-checklist.md` (correctness); `wording:` "If a function derives an entity/scope-level flag from the collection passed to it and is called on partitions of one logical set, the flag can flip per partition. Compute it once over the full set and thread it into each call."
- **Status** — pending

### Verify library-API claims against the LOCKED version's source, not current docs

- **Shape** — Before asserting or dropping a finding that a library method doesn't exist, check the source of the version pinned in the lockfile, not docs or memory.
- **Trigger signals** — a finding that turns on a method existing; evidence from web docs or memory; a recent major-version bump.
- **Evidence**
  - `- {type: caught, ref: PR #25913, date: 2026-06-01}` — a drafted blocker said `get_embedding_dimension()` doesn't exist; `uv.lock` pinned sentence-transformers 5.5.1, where it's canonical and the old name is deprecated.
- **Proposed promotion** — `target: gotchas.md`; `wording:` "**Category:** failure-mode. **Context:** a finding (or a DROP) turns on whether a library method exists. **Wrong:** asserting it from online docs, another version, or memory. **Right:** read the source of the version pinned in the lockfile. **Why:** version-skewed API knowledge produces both false blockers and false DROPs."
- **Status** — pending

### Unbounded prefix match/delete without a delimiter boundary over-matches sibling keys

- **Shape** — A prefix match or delete on a structured, variable-width key without a delimiter anchor or LIKE escaping also hits sibling keys — silent data loss on delete paths.
- **Trigger signals** — `startswith`/`LIKE 'x%'` on a structured key column; non-fixed-width ids; a prefix without a trailing delimiter; no `autoescape=True`.
- **Evidence**
  - `- {type: caught, ref: PR #25913, date: 2026-06-01}` — `delete_document(doc_id_prefix)` with bare doc ids would delete `runbooks:api-v2:chunk:0` when purging `runbooks:api`; fixed by anchoring on `:chunk:` with `autoescape=True`.
- **Proposed promotion** — `target: references/general-checklist.md` (data integrity); `wording:` "Prefix matches/deletes (`startswith`, `LIKE 'x%'`) on structured or variable-width keys must anchor on a delimiter (e.g. `f\"{prefix}:chunk:\"`) and escape wildcards (`autoescape=True`) — an unanchored prefix over-matches sibling keys."
- **Status** — pending

### New-service / scaffold PRs: check conformance to established sibling-service conventions, not just in-diff correctness

- **Shape** — A new-service scaffold is reviewed for in-diff correctness only and silently diverges from how sibling services are built, configured, and deployed.
- **Trigger signals** — a new app directory with its own Dockerfile, compose, config, or `core/` shim; a docstring asserting an infra fact ("dedicated DB") with no infra in the diff; a new consumer of shared prod infra. Check orchestration, container build, config loading, no-value re-export shims, data-store provisioning and capacity, and domain platform conventions.
- **Evidence**
  - `- {type: missed, ref: PR #25912, date: 2026-05-29}` — missed five divergences (compose, container build, config, observability, an unbacked "dedicated data store" claim); the author raised them.
  - `- {type: missed, ref: PR #25914, date: 2026-06-02}` — same service: missed the LLM-plumbing divergences (see that entry), showing domain conventions belong in the pass too.
- **Proposed promotion** — `target: references/general-checklist.md` (new-service conformance); `wording:` "For a PR that introduces a new service/scaffold, compare it with sibling services — orchestration/compose, Dockerfile convention, config and env loading, re-export shims, prod data-store provisioning and capacity, and domain platform conventions — and challenge any infra claim with no infra in the diff."
- **Status** — pending

### Verify execution order / privilege context before recommending a fix location in a shared runner

- **Shape** — A suggested fix in a leaf hook of a shared runner can run too late; trace the runner's invocation order and privilege context before saying where the fix goes.
- **Trigger signals** — a suggestion to put setup (schema creation, extension install, registry init) in a leaf hook owned by a migration framework, job runner, or app lifecycle.
- **Evidence**
  - `- {type: missed, ref: PR #25912, date: 2026-05-29}` — I suggested `CREATE SCHEMA` in a migration's `upgrade()`; the runner creates its schema-qualified version table before `upgrade()` runs, so it was a no-op on fresh deploys.
- **Proposed promotion** — `target: references/general-checklist.md` (fix suggestions); `wording:` "When a suggested fix depends on execution order or privileges in a shared runner/framework, trace the actual invocation order (and transaction/privilege context) before asserting where the fix goes — a leaf-hook fix can run too late."
- **Status** — pending

### A discovery-based checklist gate records only the boolean result, not the search evidence behind it

- **Shape** — A checklist gate on a search step asks only for the result ("none found"), not the search terms, scope, or matches, so a negative can't be spot-checked — worst when an AI agent runs the search.
- **Trigger signals** — a checklist item that only asks for a discovery result to be "named" or "reported"; a prompt-driven rather than tool-enforced search.
- **Evidence**
  - `- {type: missed, ref: PR #97, date: 2026-07-28}` — three new checklist gates for a GraphQL integration-test discovery step required only the named result; a bot and my earlier round both proposed citing search terms, and the final diff didn't.
- **Proposed promotion** — `target: references/general-checklist.md` (QA / checklist quality); `wording:` "When a checklist item gates on a search/discovery step's outcome, verify it requires the actual search identifiers, scope, or matched evidence, not just the result. 'None found' without evidence is unfalsifiable."
- **Status** — pending
