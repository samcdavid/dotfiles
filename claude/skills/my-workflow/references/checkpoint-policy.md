# Checkpoint Policy

Planning is intentionally conversational. A stop after each load-bearing
decision is expected, not a blocked workflow.

## Planning turn

After every substantive answer, persist the ledger and report:

- the compact sections/decisions changed;
- current confidence and largest uncertainty;
- any focused deep dive run; and
- one next decision with a recommendation, or the sync proposal.

Do not batch decisions or continue past the question in the same turn.

## Planning synchronization

Present the complete living ledger surface: need, scope, requirements,
decisions, architecture, test strategy, observability/evaluation,
migration/operations, phases, traceability, and assumptions. Ask what is wrong
or missing. Explicit confirmation synchronizes only the current plan version;
it does not authorize implementation.

## Pre-implementation stop

Run after synchronization on a later turn. Report refreshed issue context,
ledger-preflight result, sibling-overlap result, migration gate status, exact
plan version, and implementation phases. If clear, stop and request explicit
implementation authorization. If not clear, return to planning with the exact
invalidated sections.

## Implementation and review

`my-implement` stops only if blocked; otherwise it completes all phases before
one whole-plan `my-validate` gate. `implement-review` starts only after that
gate passes and owns its bounded loop and terminal stop. Do not insert planning
checkpoints into those procedures.

Resume exclusively from ledger state. A moderate-or-higher plan-version change
invalidates sync, preflight, and implementation authorization. A minor
amendment made during the pre-implementation gate records its classification,
changed sections, and carried-forward evidence, retains the passing gate for
the new version, and stops for fresh implementation authorization.
