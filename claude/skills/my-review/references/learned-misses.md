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
