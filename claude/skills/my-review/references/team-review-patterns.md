# Team Review Patterns

Patterns the lens reviewers should consider when scanning a diff. Distilled from a ~2,000-PR mining pass across senior Elixir-ecosystem developers (2022–2026): internal-monorepo backend engineers plus OSS maintainers of major Elixir libraries (Elixir core, Phoenix, Phoenix LiveView, Ash, Oban, Nerves, `req`, `phoenix_test`, `credo`, `ex_doc`, etc.).

Patterns are listed in approximate **frequency-across-reviewers** order. High-confidence patterns (≥6 independent reviewers reinforce each) are ready-to-flag. Medium-confidence patterns (3–5 reviewers) need to be weighed against the specifics of the diff.

The lens reviewers read this file when present (the orchestrator passes it into their briefs); `general-checklist.md` covers the always-on categories. This file is the *team-and-community knowledge layer* on top of that checklist.

---

## High-confidence patterns (6+ reviewers)

### 1. Naming precision — domain language, future-proofing, intent

**What to look for:** Names that encode an implementation choice the API shouldn't lock in; generic names where domain-specific ones would aid future readers; column/field names tied to a product name that may be renamed; abbreviations that read poorly out of context.

**Severity calibration:** Most reviewers flag this as **non-blocking nit**, but it becomes **blocking** when the name will appear in DB schema or public API (where renames are expensive).

**Example phrasings observed:**
- *"I've been trying to keep [product-name] out of DB columns because we'll undoubtedly rename the program at some point."*
- *"I'm not 100% sure if calling this `sub` is ok semantically… Perhaps something super explicit like: `{:service_account, credentials, impersonate_service_account: email}`"*
- *"I think just 'opts' here and anywhere else, because we will almost certainly extend this in any number of ways."*
- *"This is named unwell. This represents the 'path' to take for the strategy for the given permutation."*

---

### 2. Architecture — logic in wrong layer / module-boundary leaks

**What to look for:** Domain knowledge baked into a schema; API/HTTP/GraphQL concerns leaking into context modules; business logic in resolvers/controllers; cross-domain imports that bypass intended boundaries; data transformations sitting in the wrong layer.

**Severity calibration:** **Blocking.** The single most-prescriptive pattern across reviewers.

**Example phrasings observed:**
- *"These really belong in the api layer. You can reuse them at the api level, but pushing them down makes the BE aware of them and we want to avoid that."*
- *"We don't want internals of `X` to be used outside of `X`. We should expose this fragment as a function on `X.current_state_fragment`."*
- *"Api calls inside a repo transaction is a flakey pattern. We would hold the db transaction open for this and may end up timing out."*
- *"This *should* be handled by the changeset logic before it gets here. I think we may need to fix this in core somewhere."* (kicking the fix upstream to where the boundary belongs)
- *"Rather than an extra process here, we can put everything that this genserver is doing inside of the `Phoenix.Presence` module."*

---

### 3. Existing utility / pattern reuse — call out duplication

**What to look for:** New code that reimplements a function/utility/factory already in the codebase; deviation from established conventions (factory helpers, query modules, preload patterns); reaching for a library to do something the framework already supports.

**Severity calibration:** **Blocking** when the existing utility solves the same problem; **non-blocking suggestion** when adoption is preference-driven.

**Example phrasings observed:**
- *"Always use `drain_jobs` from Oban.Pro.Testing instead. It has better defaults, more options, and is designed to work with the Smart engine specifically."*
- *"If we make the suggested change to the launch rule (preload in launch module) — then we can follow the established pattern of using `build` instead of `insert!`."*
- *"This should be using `prepare_update_multis` to ensure all user updates go through the same logic."*
- *"No need for a library if this ^ is all we need for now."*
- *"if you set `:json`, Req will automatically set both accept and content-type to json so explicitly setting those headers is not necessary."*

---

### 4. Test fidelity / placement / vacuous tests

**What to look for:** Tests that assert on shape without asserting on values; tests in the wrong file or layer (integration tests where unit tests belong); missing happy + failure paths; tests that depend on ordering or timing without guarantees; tests that "pass" because the setup doesn't actually exercise the code.

**Severity calibration:** **Blocking** for missing tests on new logic; **non-blocking** for placement/style.

**Example phrasings observed:**
- *"A test like this should in the `screener_cloner_test` file as well. We should test the happy and failure path there."*
- *"This test will flake eventually. There is no guarantee that the order will be different."*
- *"Do we need a test?"* (one-line probe; common from upstream maintainers on PRs adding new code paths)
- *"This will break the tests below that assert on `File.exists?/1`, since a dev can screw up the screenshot functionality, but if they ran the test previously on a working version, the test will still pass."*
- *"Could we remove one of them? Are we testing this path? If not, can we add a test that covers this?"*

---

### 5. DB safety — migrations, indexes, atomic operations, N+1

**What to look for:** NOT NULL constraints on large tables without `NOT VALID` two-step; missing down migrations; column types that don't match domain (money as integer/float); query operators that won't use existing indexes (`->>` vs `@>`); index column order misaligned with hot-path WHERE clauses; preloads that generate N+1; queries that should fold into one.

**Severity calibration:** **Blocking** for migration safety and contract-breaking writes; **non-blocking optimization** for preload efficiency and index suggestions.

**Example phrasings observed:**
- *"I'm not sure about having a down. Setting the not null constraint can cause an outage as it could take a long time to double check all the rows."*
- *"The `->>` operator can't use the standard args index. Favor using the `@>` operator instead."*
- *"Hot path — `pendingNotifications: WHERE user_id = ?` … wants leading `user_id`."*
- *"If I use `|> preload(:arm_screener)` that will make 2 repo calls AFAIK. If I use `|> preload([_, r], [arm_screener: r])` then they are effectively identical."*
- *"That is unsafe as we're making N inserts for N permissions."*

---

### 6. Library/framework idiom expertise — call out non-idiomatic usage

**What to look for:** Use of OSS-version helpers where a Pro/internal version is expected (e.g. `drain_queue` vs `drain_jobs`); manual HTTP headers when the client (Req, Finch) sets them automatically; manual JSON parsing when a typed wrapper exists; reinvention of stdlib primitives (`Path.join`, `Map.new` with mapper, `MapSet.new` with mapper).

**Severity calibration:** **Blocking** when the idiomatic version has correctness implications; **non-blocking** when purely ergonomic.

**Example phrasings observed:**
- *"`Exception.format_mfa/3` returns a string, so using `inspect/1` escapes the quotes."*
- *"Since this will be running on every node, we need to use `Phoenix.PubSub.local_broadcast/3` to only deliver the present diff to our node-local subscribers."*
- *"It must use the `Kernel.ParallelCompiler.pmap`. Using `Task` is wrong as it cannot track modules."*
- *"This can be done in a single pass with `Map.new(params, &replace_unused/1)`."*

---

### 7. API design — defaults that hide bugs, bang vs non-bang, error returns

**What to look for:** `Map.get(thing, key, default)` where the value is logically guaranteed (should be `Map.fetch!`); fallback defaults that silently allow misconfigured production usage; non-bang functions where a missing match should crash; bang functions where the caller can't handle the raise.

**Severity calibration:** **Blocking** when defaults can hide prod bugs or auth bypasses; **question** for surfacing whether nil is actually possible.

**Example phrasings observed:**
- *"Do not fallback to localhost. It should just return an error."*
- *"Do not set defaults for things. If these required fields are missing, it should just return an error."*
- *"This should never hit the default empty map. Should this be `Map.fetch!`?"*
- *"Is this actually what we want? Shouldn't we raise in this case? … I don't think dev convenience justifies this default which can lead to weird prod bugs."*
- *"The general practice is to not allow null values as they tend to hide the meaning behind them."*
- *"Use `struct!` here and elsewhere in this file so we catch typos."*

---

### 8. Scope discipline — "this could be a separate PR"

**What to look for:** Unrelated cleanup bundled with a feature; multiple concerns that could each be reverted independently; rename + bug fix in one PR; refactor + new behavior in one PR.

**Severity calibration:** **Blocking direction.** Most reviewers ask the author to split rather than blocking merge; some upstream maintainers block-and-cherrypick.

**Example phrasings observed:**
- *"This could be a separate PR."*
- *"In the future please submit multiple PRs, as I still individually review all code changes and doing multiple changes makes the process harder."*
- *"This should be a separate step in the bulk_resume_assignments Multi."*
- *"Out of scope for this PR though: extracting it would touch the existing two caches…"*

---

### 9. Premature abstraction / YAGNI

**What to look for:** New helper module extracted from one call site; protocol/behaviour introduced before a second implementation exists; generic config option for hypothetical future use; defensive abstraction that obscures the divergence it claims to unify.

**Severity calibration:** **Blocking design** when the abstraction will set precedent; **non-blocking discussion** when contained.

**Example phrasings observed:**
- *"Introducing two classes + a package feels a bit too much for two functions which are only used in this class. Maybe start by adding these functions as private methods of this class, and then we'll move to a more elaborate design if needed?"*
- *"The caches lookup mechanisms are quite different. This feels like a premature optimization."*
- *"No need for a `Multi` here since there's only one op."*
- *"Skipping — preferring pragmatic duplication over a premature abstraction. The repeated 3-line pattern lives in 6 consumers, but the call shapes diverge enough that a helper would only DRY out one of three lines and obscure the differences."*

---

### 10. Documentation hygiene — `@moduledoc false`, `@doc false`, specs on public surface

**What to look for:** New public-looking modules without explicit privacy marker; internal helpers exposed in HexDocs; public functions missing `@spec`; docstrings missing on new schemas / types.

**Severity calibration:** **Non-blocking** for many projects (with bias toward fixing in the same PR); **blocking** when the project's policy is "every public function needs a spec" (Ash, Phoenix, similar frameworks).

**Example phrasings observed:**
- *"These aren't public facing functions (I think) and they should have `@doc false`."*
- *"`Operations` is not a part of the public API. It's explicitly marked with `@moduledoc false`, which makes it internal."*
- *"if you ever see anything without type specs or docs and you'd like to add them, please do not hesitate. Every public function should have specs and docs eventually ❤️"*
- *"Would be nice to see `@moduledoc` on these new schemas."*
- *"Since this is private, I tend to make these `@moduledoc false`… that way, the module isn't visible from hexdocs, and people don't use it directly."*

---

## Medium-confidence patterns (3–5 reviewers)

### 11. Concurrency / process safety

**What to look for:** New `GenServer` where a `try/rescue` would suffice; supervisor restart strategy that won't actually catch repeat crashes (1-in-1-sec semantics); missing trap_exit; race conditions in state lookup → action sequences; external HTTP calls inside `Repo.transaction`/`Multi`.

**Example phrasings observed:**
- *"This doesn't do what it sounds like it should. What it says is that the supervisor only allows for 1 restart in 1 second. If `X` were to exit a second time in a second, then it wouldn't be restarted again."*
- *"Sorry, I don't get why we need a GenServer. I get that the issue is that the hub itself may be unavailable, but I'd rather do a try/rescue."*
- *"Api calls inside a repo transaction is a flakey pattern."*
- *"Rather than an extra process here, we can put everything that this genserver is doing inside of the `Phoenix.Presence` module."*

---

### 12. Pattern matching over runtime branching

**What to look for:** `case`/`if`/`cond` chains in function bodies where pattern-matched function heads would be cleaner; `with` chains that have grown beyond a single catch-all `else` clause; defensive `Map.get(map, :key, nil)` rather than pattern-match destructuring.

**Example phrasings observed:**
- *"Let's pattern match on the args as it was done before!"*
- *"This is hiding a `Enum.reduce_while`."*
- *"with/1 is ideal without else clause or with a single catch-all else clause, anything other than that gives me a pause every single time."*

---

### 13. Authorization scope / required-field enforcement

**What to look for:** New endpoints/routes without explicit authorization; mutations accessible to viewers/contributors who shouldn't be able to call them; auth tokens exposed to callers other than the authenticated user; client-sent IDs used to authorize without server-side membership check.

**Example phrasings observed:**
- *"These endpoints need authorization. There should be a standard authorization pattern."*
- *"We need authorization to be added in THIS PR."*
- *"Probably we need to exclude staff users there. Maybe we would want to also exclude viewers."*
- *"We should exclude contributors and viewers in there, right? The mutation can be called by anyone."*

---

### 14. Runtime vs compile-time config

**What to look for:** `Mix.env()` or `Application.compile_env` in code that runs in a release; provider-/host-specific config baked at compile time that should live in `runtime.exs`.

**Example phrasings observed:**
- *"This is going to fail when deployed because Mix is not available."*
- *"All this needs to go into `runtime.exs` I think. Consolidate."*
- *"In hindsight, another idea is this contract: 1. we do more work at compile-time. We'd need to `mix deps.compile --force myxql` when swapping codecs though."*

---

### 15. Question-first review style — "Why this change?" before prescribing

This isn't a defect pattern — it's a *style* pattern. When the diff has a non-obvious change, the most-effective reviewers ask the author's intent before evaluating. Adopt this style for non-trivial diffs from any contributor.

**Example phrasings observed:**
- *"Out of curiosity, why this change? Might be obvious, and I'm just missing it."*
- *"I don't mind the change, but just curious, any reason why we want to make this change?"*
- *"🎓 I'm guessing this still works with `fish`?"*
- *"Was something failing without this?"*
- *"Are there instances where the name, label, or choices are null? The defensive coalesce wouldn't harm anything, I'm just curious."*

---

### 16. Code-suggestion blocks as default review format

Most high-volume reviewers in the sample write their corrections as ` ```suggestion ` blocks rather than prose. Roughly 50%+ of inline review comments are suggestion blocks for the most prolific reviewers.

**Application to reviewers:** When a finding has a one- or two-line fix, render it as a ```suggestion block in the Fix section. Authors apply these with one click — fastest path to resolution.

---

### 17. Observability hygiene — OTel context, telemetry, log-correlation, structured Logger metadata

**What to look for:** New code paths missing `Logger` calls; `Task.async` and similar that don't re-attach OTel context; telemetry events on hot paths using captures (which warn); Logger metadata keys outside the project's allowlist that get silently dropped.

**Example phrasings observed:**
- *"Basically, anywhere we call `Task.async` or similar, we need to re-attach the otel context so traces can continue."*
- *"We want `&__MODULE__.live_view_mount_stop/4` for these otherwise telemetry will warn about performance for captures."*
- *"The `:otel_simple_processor` is a global process. This is what ends up sending the spans to the exporter in real environments…"*

---

### 18. HTTP / spec compliance — RFC citations, headers, content-length

**What to look for:** Manual HTTP header construction that overrides what the client library handles; content-length / transfer-encoding mismatches; header names that don't match the RFC; field names that don't match the underlying protocol.

**Example phrasings observed:**
- *"Per RFC 7578 §4.8: 'The multipart/form-data media type does not support any MIME header fields in parts other than Content-Type, Content-Disposition…'"*
- *"Maybe it can even be something like: `if size = multipart.size do Req.Request.put_new_header(req, \"content-length\", Integer.to_string(size))`"*

Use when the diff touches HTTP-protocol code; the most-effective reviewers cite the RFC inline rather than waving at it.

---

### 19. AI-bot review fact-checking

When the codebase uses an AI reviewer (CodeRabbit, similar) for routine review, AI-generated findings need independent verification before being incorporated. Established convention is to verify-then-respond with `**AI fact check:**` framing, citing actual source code.

**Example phrasings observed:**
- *"**AI fact check:** This claim is inaccurate. `build(:sms, status: :sent)` already works via the catch-all clause at `factory.ex:1856`."*
- *"**AI fact check:** Real bug — confirmed in `deps/ecto/lib/ecto/changeset.ex:2470` (inside `validate_change/3`)."*

If the diff has AI-bot review comments in the dedupe index, surface fact-check verifications rather than treating bot claims as authoritative.

---

## Lens severity calibration (when to block vs. nit)

Most reviewers in this sample use explicit severity labels on inline comments. Reviewers should emit findings using the same idiom so authors can triage fast:

- **Bug:** / **Bug** — correctness issue with concrete consequence
- **Nit:** — non-blocking style/naming/cleanup
- **Suggestion (non-blocking):** — improvement worth raising but not blocking merge
- **Question:** — needs author's context to decide
- **AI fact check:** — used specifically when challenging an AI reviewer's finding

Categories that are **blocking by default** across the sample: layering / module-boundary violations, missing authorization on new endpoints, defaults that hide bugs, split-the-PR direction, race conditions / unsafe migration patterns, missing tests on new behavior.

Categories that are **non-blocking question-first**: naming nits, preload efficiency, documentation hygiene on satellite code, "why this change?" intent probes.

---

## Reviewer archetypes (when to flag what)

These are common reviewer styles, not specific people. Adopt the matching archetype based on the lens(es) active and the codebase area:

- **The library-internal expert** — knows the codebase's frameworks deeply, catches OSS-vs-Pro confusions, suggests existing helpers by name. Strong signal in lens areas where there's an authoritative library (Oban, Phoenix, Ecto, Ash).

- **The architecture-layering reviewer** — owns the "what belongs where" judgment. Flags resolver→context leaks, schema modules with domain logic, cross-domain imports. Bias toward 2-paragraph prose for blocking findings.

- **The empirical/AI-era reviewer** — verifies every claim against source code or queries before accepting. Splits responses into "Real bug — fixed in `<sha>`" vs "False positive — here's the evidence". Use when the codebase has AI reviewer noise.

- **The Socratic reviewer** — asks "Why this change?" / "Was X failing?" before prescribing. Catches motivation gaps; good calibration when reviewing unfamiliar areas or new contributors.

- **The DB/safety reviewer** — flags migration lock risk, index alignment, transaction atomicity, hot-path query analysis. Cite specific operators and column orderings.

- **The minimalist** — pushes back on premature abstraction, unnecessary `Multi`/`GenServer`, defensive defaults. Defers helpers until ≥3 concrete consumers exist.

- **The maintainer-decisive** — when in a feature-owner role, willing to close-and-replace rather than negotiate. Use sparingly and always with transparency about the reason.

---

## Style guidance summary

When a reviewer emits a finding, calibrate against these defaults:

1. **One-line fix** → `suggestion` block. Authors apply these fastest.
2. **Architectural concern** → prose paragraph explaining the layer/boundary issue. 2-paragraph explanations are normal for blocking architectural findings.
3. **Non-obvious intent** → question-first ("Why this change?" / "Was X failing?") rather than prescribing.
4. **Severity prefix** on every inline finding: `Bug:` / `Nit:` / `Suggestion (non-blocking):` / `Question:`.
5. **Reference existing utilities by full module path** when calling out duplication. Don't say "use the helper" — name it (`SubmissionQuery.standard_set/1`, `Account.has_feature?/2`, etc.).

---

## Mining metadata

- ~2,000 PR threads sampled across 24 senior contributors (Elixir/Phoenix/Ash/Nerves/Oban ecosystem + internal monorepo backend)
- Date range: 2022-01-01 → 2026-05-27
- Repos covered: 60+ public OSS repos (Elixir, Phoenix, Ash, Oban, Nerves, ex_doc, phoenix_test, credo, req, finch, mint, etc.) plus an internal monorepo
- Confidence: high for cross-cutting patterns reinforced by 6+ independent reviewers; medium for patterns from 3–5 reviewers
- Update cadence: one-time snapshot. Re-run when team composition shifts substantially or production reviews surface recurring patterns not captured here.
