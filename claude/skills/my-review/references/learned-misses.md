# Learned Misses — pattern queue

Patterns the skill should learn to catch (or has caught and confirmed are recurring). Entries accumulate Evidence over time. When `len(evidence) >= 3`, an entry is auto-promoted into the relevant lens reference or `gotchas.md`.

See `SKILL.md` § "Queue lifecycle and auto-promotion" for rules.

## Schema

Each entry is a markdown subsection with:

- **Shape** — the general pattern (the load-bearing field; matching new captures against existing Shapes appends Evidence rather than creating duplicates)
- **Trigger signals** — what in a diff should make the skill stop and check this pattern
- **Evidence** — list of `- {type: caught|missed|noted, ref: <pr#/comment-link/session>, date: YYYY-MM-DD}` entries
- **Proposed promotion** — optional at capture; `target: <file>` + draft `wording:` (required for hard auto-promote — otherwise target is inferred and wording is generated)
- **Status** — `pending` | `ready` | `promoted (YYYY-MM-DD)` | `discarded (YYYY-MM-DD, reason)`

## Pending

<!-- Entries with status: pending or ready live here. Order: most recently updated first. -->

### Verify library-API claims against the LOCKED version's source, not current docs

- **Shape** — Before asserting (or DROPping) a finding that a code path calls a non-existent / wrong / renamed library method, verify the method against the **source of the version actually locked** (`uv.lock` / `package-lock` / `Gemfile.lock`), not against current online docs or memory. Major-version renames and package restructures make docs and intuition stale — the locked version is what runs. A method that "doesn't exist" in the docs may be the canonical one at the pinned version (or vice-versa).
- **Trigger signals** — a review finding hinges on a library method name/signature existing or not; the claim is grounded in web docs, a different version's source, or memory rather than the pinned version; the dependency has had a recent major version bump or known API rename; the symptom would be an AttributeError/NoMethodError at runtime that no test covers.
- **Evidence**
  - `- {type: caught, ref: PR #25913, date: 2026-06-01}` — review drafted a blocking "calls non-existent `get_embedding_dimension()`; correct API is `get_sentence_embedding_dimension()`" finding from sbert.net docs. Checking `uv.lock` (sentence-transformers 5.5.1) showed the package was restructured: `get_embedding_dimension()` is now canonical and `get_sentence_embedding_dimension()` is the `@deprecated` alias. The locked-source check converted a false blocker into a correct DROP.
- **Proposed promotion** — `target: gotchas.md`; `wording:` "**Category:** failure-mode. **Context:** a finding (or a DROP of one) turns on whether a library method/signature exists. **Wrong:** asserting it from current online docs, a different version, or memory. **Right:** read the source of the version pinned in the lockfile (uv.lock / package-lock / Gemfile.lock) — major-version renames and restructures make docs stale; the locked version is what runs. **Why:** both false blockers and false DROPs come from version-skewed API knowledge; the lockfile is the only authoritative reference for what the code actually calls."
- **Status** — pending

### Unbounded prefix match/delete without a delimiter boundary over-matches sibling keys

- **Shape** — When a query matches or deletes rows by a string **prefix** (`col.startswith(x)`, `LIKE 'x%'`, `key LIKE prefix||'%'`), check that the prefix is anchored on a structural delimiter and that LIKE wildcards in the prefix are escaped. Without a boundary, a prefix that is a substring-prefix of a longer sibling key (variable-width IDs, path-like keys) matches/deletes the sibling too — silent over-deletion / data loss on delete paths, false positives on read paths.
- **Trigger signals** — a `delete`/`select`/`where` uses `startswith` / `LIKE 'prefix%'` / `ilike` against a structured key column; IDs follow a `a:b:c:chunk:n` or path-like scheme and are **not fixed-width**; the prefix is caller-supplied without a trailing delimiter; `startswith`/`like` is used without `autoescape=True` on keys that can contain `_` or `%`.
- **Evidence**
  - `- {type: caught, ref: PR #25913, date: 2026-06-01}` — `delete_document(doc_id_prefix)` used `Document.id.startswith(doc_id_prefix)` and was called with bare doc ids; because chunk IDs are `{doc_id}:chunk:{n}` and doc ids aren't fixed-width, purging `runbooks:api` would also delete `runbooks:api-v2:chunk:0`. Fix: anchor on `:chunk:` and `autoescape=True`.
- **Proposed promotion** — `target: references/general-checklist.md` (data-integrity check); `wording:` "Prefix matches/deletes (`startswith`, `LIKE 'x%'`) against structured/variable-width key columns must anchor on a structural delimiter (e.g. `f\"{prefix}:chunk:\"`) and escape LIKE wildcards (`autoescape=True`) — an unanchored prefix over-matches sibling keys (silent data loss on delete paths)."
- **Status** — pending

### New-service / scaffold PRs: check conformance to established sibling-service conventions, not just in-diff correctness

- **Shape** — When reviewing a PR that stands up a **new service or scaffold** in an established (esp. polyglot mono-)repo, run an explicit conformance pass against how *existing sibling services* are built and deployed — don't just verify the correctness of the code in the diff. The common miss is approving a self-consistent scaffold that silently diverges from house patterns (build/deploy/config/infra).
- **Trigger signals** — a PR adds a new app/service directory, its own `Dockerfile` / `docker-compose` / config module / settings class / observability or other `core/` shim; a docstring asserts an **operational/infra fact** ("its own dedicated DB instance", "isolated") with **no infra (Terraform/compose/manifest) in the diff** to back it; the new service is a consumer of shared prod infra (a shared DB, queue, cache). Conformance axes to check against siblings: shared orchestration / compose integration (+ shared dependency services, image/version pins); container build convention (multi-stage, shared/base image); config & env-loading convention (single source of truth); thin re-export "seams" that add no value vs how siblings import shared libs; and **prod data-store / infra provisioning + capacity** (does a new consumer land on already-loaded shared hardware?).
- **Evidence**
  - `- {type: missed, ref: PR #25912, date: 2026-05-29}` — reviewed a new-service scaffold multiple times, anchoring on in-diff correctness (a migration); missed five conformance gaps — divergence from sibling-service orchestration/compose, container-build, config, and observability conventions, plus a docstring asserting a *dedicated* data-store instance with no infra in the diff to back it (against shared prod hardware). The PR author surfaced all five, not the reviewer.
- **Proposed promotion** — `target: references/general-checklist.md` (a cross-cutting "new-service conformance" review category); `wording:` "For a PR that introduces a new service/scaffold, run a conformance pass against existing sibling services — orchestration/compose integration (+ shared deps, image/version pins), Dockerfile multi-stage/base convention, config & env-loading convention, no-value re-export shims, and prod DB/infra provisioning + capacity (a new consumer on shared/loaded hardware) — and challenge any docstring that asserts an operational/infra fact with no infra in the diff. Don't approve a self-consistent scaffold that diverges from house patterns."
- **Status** — pending

### Verify execution order / privilege context before recommending a fix location in a shared runner

- **Shape** — When recommending a fix whose correctness depends on *when* or *with what privileges* a shared runner/framework invokes a hook, trace the actual call order (and transaction/privilege context) before asserting the fix location. A fix placed in a leaf hook (e.g. a migration's `upgrade()`) can be too late if the framework runs other schema-qualified or privileged bookkeeping first.
- **Trigger signals** — a review suggests adding bootstrap/setup code (schema/namespace creation, extension/plugin install, table or registry init, env/lifecycle setup) to a leaf hook owned by a shared runner (a migration framework like Alembic, a job/queue runner, an app lifecycle/startup sequence); a managed-resource privilege model or transaction/savepoint wrapping is in play; the fix's effectiveness hinges on the framework's invocation order rather than the leaf code itself.
- **Evidence**
  - `- {type: missed, ref: PR #25912, date: 2026-05-29}` — review recommended adding `CREATE SCHEMA` to a migration's `upgrade()`; re-review found the shared migration runner creates schema-qualified bookkeeping (a version-tracking table) *before* `upgrade()` runs, so the leaf fix was a no-op for fresh deploys.
- **Proposed promotion** — `target: references/general-checklist.md` (a cross-cutting "fix-suggestion" review check); `wording:` "When a review's suggested fix depends on execution order or privileges in a shared runner/framework the author didn't write, trace the actual invocation order (and transaction/privilege context) before asserting *where* the fix goes — a leaf-hook fix can run too late."
- **Status** — pending

## Promoted

<!-- Entries with status: promoted (preserved for audit, never deleted automatically). -->

_No promoted entries._

## Discarded

<!-- Entries with status: discarded (preserved for audit, never deleted automatically). -->

_No discarded entries._
