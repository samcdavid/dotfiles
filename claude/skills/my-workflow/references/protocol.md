# Protocol — my-workflow

`my-workflow` coordinates one collaborative planning document, a fresh
pre-implementation gate, and the existing implementation/review loop. The
workflow ledger is both the resume source of truth and the approved plan.

## Governing constraints

1. **Pair before implementation.** Planning is a real back-and-forth
   conversation, not an autonomous sequence of artifact-producing stages.
2. **One canonical document.** The local workflow ledger holds the need summary,
   decisions, requirements, architecture, tests, observability/evaluation,
   migrations, and implementation phases. Do not create separate planning
   artifacts inside this workflow.
3. **Issues say what; the ledger says how.** Read the complete issue corpus, but
   record only the load-bearing need and source references. Do not copy issue
   descriptions/comments into the ledger.
4. **Research facts; discuss decisions.** Resolve knowable facts from sources.
   Ask one user-owned, load-bearing decision at a time with a recommendation.
5. **Deep dive on demand.** Reuse existing specialist agents for precise
   uncertainties. Do not run the former research/spec/clarify/architecture/
   test/plan/observe/eval/analyze pipeline wholesale.
6. **Persist every turn.** Update the ledger after each substantive decision or
   deep dive so clearing context never loses planning state.
7. **Sync is not implementation authority.** A synchronized plan must pass the
   fresh pre-implementation gate, then receive separate explicit authorization.
   A minor amendment discovered by that gate carries its successful gate
   evidence forward; a moderate or higher correction requires a new sync and
   gate.
8. **Whole-plan validation before review.** `my-implement` completes every
   phase and its holistic test gate, then `my-validate` runs once against the
   completed plan before `implement-review` begins. Validation after a review
   repair remains part of `implement-review`; keep its five-pass cap unchanged.
9. **Migration safety is staged.** Before implementation, require a migration
   design, test-suite migration execution, and a concrete staging-validation
   plan from `migration-safety.md`. Validate current database state only during
   the developer's staging deployment; its pending result does not block local
   planning, implementation, validation, or review.
10. **No outward actions.** Local planning writes and validated implementation
    commits are allowed. Pushes, PR mutations, published messages, deployments,
    and other remote changes require explicit authorization.

## Pipeline

| # | Stage | Produces | Stop |
| --- | --- | --- | --- |
| 0 | Intake and route | matched/new ledger or explicit `my-quick` handoff | route confirmation when quick |
| 1 | `my-pair-plan` | living ledger at synchronized plan version | every conversational turn; final planning sync |
| 2 | Pre-implementation gate | refreshed sources, consistency audit, sibling check | overlap, drift, or gate failure |
| 3 | Implementation authorization | explicit user approval recorded | always before code changes |
| 4 | `my-implement` | phase commits + holistic test evidence | only if blocked |
| 5 | `my-validate` | one whole-plan validation outcome | validation failure/blocker |
| 6 | `implement-review` | bounded review/repair outcome | terminal result |

## Step 0 — Intake and ledger detection

Run `git branch --show-current` before matching the task.

- On a feature branch, a ledger with matching `branch` is authoritative. Resume
  it and use its recorded task. Never create a second ledger for that branch
  unless the user explicitly abandons/replaces the first.
- On `main`/`master`, or when no branch match exists, fall back to Linear ID,
  issue slug, then topic.
- Parse a Linear issue/URL, supplied file/URL, free-text request, or current
  conversation only after ledger detection.

Use `stage-routing.md` to choose full workflow versus `my-quick`. Migration work
always takes the full workflow. If quick applies, create/update the ledger with
the route, reason, expected scope, and exact command, then stop for confirmation
before invoking it.

For the full workflow, dispatch `my-pair-plan`. That runner creates a new ledger
when needed from its template and owns subsequent planning updates.

### Legacy workflow ledgers

If a ledger uses the former stages 1–9, do not rerun them automatically. Read
their artifacts, synthesize their still-current decisions and content into the
living-ledger sections, record the imported paths under a legacy note, set
`planning_status: sync_pending`, and require one user sync. The old Decisions
Checkpoint does not by itself satisfy the new pre-implementation gate.

## Step 1 — Collaborative planning

Dispatch `skill-my-pair-plan` in `collaborative_planning` mode with task,
ledger path, current user response, and local-only authority. The runner:

- reads the current issue and required sibling corpus fully;
- records a synthesized need/source index;
- performs brief code orientation;
- maintains requirements, decisions, architecture, behavior-first tests,
  observability/evaluation, migration/operations, implementation phases, and
  traceability in the ledger;
- uses current specialist agents only for focused deep dives; and
- returns one next decision or a sync proposal.

Present its compact delta and question in plain language, expanding every
requirement, decision, test, and phase reference before any optional ID. Render
the returned `code_context` immediately before the decision: clickable
file/start-line, one sentence explaining what matters, and the fenced excerpt.
For `kind: proposed`, label it as a sketch rather than current repository code.
Do not ask the question without this context. End the turn. On the user's answer,
re-dispatch the same ledger and response. Do not answer on the runner's behalf,
batch its questions, or continue into implementation in the same turn.

When the runner proposes synchronization, present the complete planning surface
and ask what is wrong or missing. Only explicit confirmation marks the current
`plan_version` synchronized. Corrections invalidate the sync, update the ledger,
and resume the pairing loop.

## Step 2 — Pre-implementation gate

Run only after `planning_status: synchronized`. Never fold this gate into the
sync turn.

1. **Refresh source needs.** Re-fetch the current issue and exact sibling scope
   from `cross-workflow-coordination.md`, reading titles, descriptions, and all
   comments. Compare the synthesized need against the ledger's retrieval
   version. If load-bearing intent changed, invalidate sync and return to
   `my-pair-plan` with the delta.
2. **Audit the one document.** Dispatch `skill-my-analyze` with
   `mode: ledger_preflight`, the ledger path, and current plan version. It checks
   internal contradictions, unresolved decisions, scope, requirement → test →
   phase coverage, phase executability, observability/eval applicability, and
   migration requirements. It returns findings, not a separate artifact.
3. **Coordinate siblings.** Apply the fresh overlap check in
   `cross-workflow-coordination.md` against exact planned files, modules,
   contracts, and requirements. Stop only for a material overlap decision.
4. **Check migrations.** When required, confirm the ledger contains the
   migration design, test-suite command and expected migration evidence, and
   staging-validation checklist from `migration-safety.md`. Do not require
   current-database inspection, historical-state reconstruction, or staging
   results at this local gate.

If a check needs a planning correction, classify it before changing the ledger:

- **Minor:** a clarification, wording correction, or implementation-detail
  adjustment that preserves the approved need, requirements and non-goals,
  affected files/modules/contracts, architecture, test contracts, migration and
  operational obligations, and phase ordering. Make this amendment directly in
  the synchronized ledger; increment `plan_version`; retain
  `planning_status: synchronized` and `pre_implementation_check: passed`; set
  `checked_plan_version` to the new version; and append the reason, changed
  sections, classification, and carried-forward gate evidence under
  `Pre-Implementation Check`. Do not re-sync or rerun the source refresh,
  ledger audit, sibling check, or migration check. Continue directly to Step 3
  and ask for explicit implementation authorization for the amended plan.
- **Moderate or higher:** any change to the approved need, requirement,
  non-goal, scope/affected surface, contract, architecture, test contract,
  migration/operational obligation, phase ordering, or a change whose impact is
  uncertain. Set `planning_status: pairing`, increment `plan_version`, clear
  the sync, preflight, and authorization state, record the reason, and resume
  `my-pair-plan`; it must be synchronized and pass a fresh gate.

When all checks pass without a correction, record:

```yaml
pre_implementation_check: passed
checked_plan_version: <current version>
pre_implementation_checked_at: <timestamp>
issue_context_refreshed_at: <timestamp>
```

The gate's success permits asking for implementation authorization; it does not
provide that authorization.

## Step 3 — Implementation authorization

Present the synchronized ledger path/version, gate evidence, exact phases,
affected surfaces, test strategy, migration/operational requirements, and any
remaining assumptions. Ask explicitly whether to implement this plan.

Describe each phase by the behavior it delivers and each remaining assumption
by its actual content. Do not present phase numbers or ledger keys as if the
user already knows their meaning.

Only an affirmative response sets `implementation_authorized: true`,
`authorized_plan_version: <current version>`, and
`implementation_authorized_at: <timestamp>`. A moderate-or-higher planning
correction clears the sync, gate, and authorization fields and returns to
pairing. A minor amendment made during Step 2 has already carried its gate
evidence to its new version, but still requires this fresh authorization. Never
reuse authorization after the plan version changes.

## Step 4 — Existing implementation loop

Invoke `my-implement` in embedded mode with:

```yaml
mode: embedded
plan_path: <ledger path>
ledger_path: <same ledger path>
artifact_inputs:
  planning_document: <ledger path>
  test_strategy: <ledger path>#test-strategy
  architecture: <ledger path>#architecture
stage: implementation
authority: local_only
```

The ledger's `Implementation Plan` is the plan and its `Test Strategy` is the
binding behavior contract. `my-implement` retains sequential bounded phases,
RED → GREEN → VALIDATE, independent re-verification, local commit,
loop detection, and holistic test behavior.

Record the returned phase commits and evidence in `Execution Log`. If it blocks,
stop. Only complete implementation permits stage 5.

## Step 5 — Whole-plan validation

Dispatch `my-validate` once in embedded mode with the completed implementation
evidence and the same plan, ledger, and base context:

```yaml
mode: embedded
plan_path: <ledger path>
ledger_path: <same ledger path>
artifact_inputs:
  planning_document: <ledger path>
  test_strategy: <ledger path>#test-strategy
  architecture: <ledger path>#architecture
  implementation_evidence: <Step 4 outcome>
stage: post_implementation_validation
authority: local_only
```

Record its checks, coverage, repairs, local commits, residual risks, and
outcome in `Execution Log`. A blocked or failed result stops the workflow. Only
a passing result permits review; do not run this whole-plan gate again between
review passes. Validation that `implement-review` performs after a repair stays
within that review loop.

## Step 6 — Existing review loop

Dispatch `skill-implement-review` with completed implementation and whole-plan
validation evidence, the ledger as requirements/plan/test context, base ref,
and local-only authority.
It remains the sole owner of `my-review` → repair → `my-validate` → `my-review`,
capped at five review passes. Do not interleave implementation or run a second
repair loop.

After its terminal result, run the final sibling-state refresh retained in
`cross-workflow-coordination.md` and render `final-report.md`.

## Resume rules

Read the ledger first and route from durable state:

- `context`, `pairing`, or `sync_pending` → `my-pair-plan`;
- `synchronized` without a passing current-version preflight → Step 2;
- preflight passed without current-version authorization → Step 3;
- authorized implementation incomplete → Step 4;
- implementation complete, whole-plan validation incomplete → Step 5;
- whole-plan validation passed, review incomplete → Step 6;
- review terminal → final report.

Never infer completion from loose artifacts, conversation memory, old plan
versions, or a previous workflow's authorization.
