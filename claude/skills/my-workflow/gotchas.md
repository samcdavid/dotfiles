# my-workflow — Gotchas

## Starting a second ledger for an existing branch

Detect the current branch before parsing the request. A feature-branch ledger
is authoritative unless the user explicitly abandons or replaces it. On the
default branch, fall back to issue ID/slug/topic because multiple planning
ledgers may coexist.

## Copying issue prose into the ledger

Read the complete current/sibling issue corpus, but write only the load-bearing
need, constraints, dependencies, and source references. The issues explain what
is needed; the ledger explains how to meet it.

## Treating pair planning as a disguised stage pipeline

Do not automatically invoke research, spec, clarify, architecture, test, plan,
observe, eval, and analyze runners. `my-pair-plan` owns synthesis; existing
agents are focused specialists invoked only for a concrete uncertainty.

## Batching decisions

Pair planning asks one load-bearing decision at a time with a recommendation,
then updates the ledger immediately. Do not accumulate provisional decisions for
one late reveal or force the user to review several unrelated choices at once.

## Asking a factual question

Research facts from issues, code, docs, or focused agents. User attention is for
product intent and trade-offs that evidence cannot settle.

## Letting conversation history become state

The ledger must reflect every substantive decision before the turn ends.
Conversation memory, a subagent transcript, or a loose artifact is not durable
workflow state.

## Treating synchronization as implementation permission

Sync approves the planning document only. Run the fresh issue/consistency/
sibling preflight on a later turn, then obtain separate explicit authorization
before dispatching `my-implement`.

## Reusing a stale preflight

A moderate-or-higher plan-version change invalidates synchronization,
preflight, and implementation authorization. A minor amendment discovered
during the pre-implementation gate is the narrow exception: record its
classification, changed sections, and carried-forward evidence, then ask for
fresh implementation authorization without re-syncing or rerunning the gate.
Never use that exception for a requirement, scope, contract, architecture,
test, migration/operations, phase-order change, or uncertain impact.

## Silently switching to my-quick

Record the route, reason, scope, and handoff in the ledger, present it, and wait
for approval. Migration work never uses `my-quick`.

## Skipping whole-plan validation before review

`my-implement` owns every plan phase and its holistic test gate. Run one
whole-plan `my-validate` after that completion; `implement-review` begins only
when it passes and remains the sole review/repair-loop owner. Validation after a
review repair remains inside the review loop.

## Requiring staging migration proof before local review

Keep local implementation validation and deployment validation separate. Run
the generated migration locally with the repository's normal migration command
(`mix ecto.migrate` for Axon) and complete local tests before review. Staging
migration, artifact, and physical-schema evidence can only be collected after a
PR exists and a staging deployment is kicked off; record it as a later
deployment gate, not as a blocker for local implementation or review.

## Cargo-culting operational directives

Reconcile ticket claims with current code and retained gotchas before planning.
For example, do not copy a `:follower_db` directive into Axon platform reads
without verifying that the current local routing convention actually uses it.

## Forgetting the remote boundary

Validated implementation phases and repairs commit locally. Never push, open or
update a PR, publish replies, resolve threads, or deploy unless explicitly
requested.
