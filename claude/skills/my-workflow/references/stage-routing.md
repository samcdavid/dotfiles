# Stage Routing

Read the branch-matched workflow ledger before routing. Loose artifacts are
evidence only; they never authorize implementation.

## Route selection

Migration work always uses the full workflow. Read `migration-safety.md` and set
`migration_safety: required` when the task touches migration versions,
persisted schema/data, or deployment-database repair.

Offer `my-quick` only for a small, well-understood refactor, semantic-free
rename, cleanup, or targeted fix whose before/after behavior and complete scope
are already predictable. Record the proposed route, reason, scope, and handoff
in the ledger, then wait for approval before invoking it.

All new functionality, contract-affecting behavior, test-specified bug fixes,
multi-module work, architecture changes, and uncertain scope use
`my-pair-plan`.

## Embedded dispatch

| Workflow stage | Runner | Purpose |
| --- | --- | --- |
| Collaborative planning | `skill-my-pair-plan` | living ledger + user dialogue + focused deep dives |
| Preflight consistency | `skill-my-analyze` with `mode: ledger_preflight` | one-document readiness audit |
| Implementation | `my-implement` | sequential bounded implementation phases |
| Whole-plan validation | `my-validate` | one final validation of completed planned work |
| Review/repair | `skill-implement-review` | unchanged bounded terminal loop |

`my-pair-plan` may dispatch existing specialists in `focused_advisory` mode:
`skill-my-architecture-plan`, `skill-my-test-strategy`, `skill-my-observe`, and
`skill-my-eval-plan`. These calls return evidence and proposed ledger patches;
they do not become workflow stages or create companion artifacts.

Standalone `my-research`, `my-spec`, `my-clarify`, `my-architecture-plan`,
`my-test-strategy`, `my-plan`, `my-observe`, `my-eval-plan`, and `my-analyze`
remain available outside `my-workflow`.

## Durable-state routing

- No ledger: create through `my-pair-plan`, unless the approved route is
  `my-quick`.
- `planning_status: context | pairing | sync_pending`: resume `my-pair-plan`.
- `planning_status: synchronized` and preflight missing/stale: run the
  pre-implementation gate. A recorded minor gate amendment with a passed
  `checked_plan_version` equal to `plan_version` routes directly to
  authorization; moderate or higher changes route through pairing and sync.
- Current-version preflight passed but implementation unauthorized: stop for
  authorization.
- Authorized current version with incomplete implementation: run
  `my-implement`.
- Implementation complete without passing whole-plan validation: run
  `my-validate` once.
- Whole-plan validation passed with nonterminal review: run `implement-review`.
- Terminal review: final report.

## Implementation gate

All conditions are mandatory:

- The ledger is the current branch's canonical document.
- `planning_status: synchronized` and `planning_synced_at` is present.
- Every decision is resolved; no requirement or traceability row is uncovered.
- Architecture, test strategy, implementation phases, and applicable
  observability/evaluation/migration sections are complete.
- `pre_implementation_check: passed` and `checked_plan_version` equals the
  synchronized `plan_version`, after the sync turn.
- For migration work, the local migration design, test-suite validation plan,
  and staging-validation checklist are complete. Successful staging validation
  is a later developer deployment responsibility, not an implementation gate.
- `implementation_authorized: true` and `authorized_plan_version` equals that
  same plan version.

If any condition is absent, return to the earliest missing planning/gate step.
Never repair the planning gap inside `my-implement`.

## Review-loop gate

Dispatch `implement-review` only when the ledger records every implementation
phase complete, all phase commits, successful holistic verification, and a
passing `post_implementation_validation` outcome from `my-validate`. Missing or
failed evidence blocks review without consuming pass 1.

Legacy ledgers with the former stages 1–9 must be synthesized into the living
ledger and explicitly synchronized before using the new gate. A previously
completed clean atomic `implement-review` remains terminal; do not reopen it
solely to migrate ledger format.
