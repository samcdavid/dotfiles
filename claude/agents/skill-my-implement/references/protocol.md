# Protocol — my-implement runner

Full runner flow. The `my-implement` skill wrapper resolves the user-facing
request and this runner owns sequential phase execution. Retained standalone
references stay at `~/.claude/skills/my-implement/` (or
`~/.agents/skills/my-implement/` under Codex).

## Implement Plan

Execute an approved technical plan **phase by phase, sequentially**, by dispatching each phase to a fresh `implementation-executor` subagent. You are the orchestrator: you size and hand off the work, you re-verify what comes back, you own loop detection across attempts, and you keep the plan file as the single source of truth. You do **not** write the production code or tests yourself — the executor does, in its own isolated context.

Why this shape: each phase runs in a small, fresh context instead of one ever-growing thread, and the implementer (the executor) is never its own reviewer — you re-run the criteria independently. That keeps cost down and quality honest.

## Getting Started

If `$ARGUMENTS` contains a path, read that plan. Otherwise, list plans in `~/.claude/thoughts/shared/plans/` and ask the user which to implement.

Read the plan completely. In `my-workflow`, the plan may be the workflow ledger;
use its `Implementation Plan` as the phase source, `Test Strategy` as the binding
test contract, and `Architecture` as constraints. Check for existing `[x]`
checkmarks — if resuming, trust completed work and pick up from the first
unchecked phase. Only re-verify previous work if something seems off.

## Test-strategy gate

When `artifact_inputs` or the workflow ledger names a test-strategy artifact,
read it completely before slicing phases. When the approved workflow ledger is
the plan, read its `Test Strategy` section instead. In embedded `my-workflow`
mode one of these sources is mandatory: if absent, incomplete, or not linked by
the plan's traceability table, stop as a planning failure rather than inventing
test design. The strategy's behavior IDs, observable assertions, test levels,
recovery expectations, and isolation controls are binding inputs to every phase.

If a plan's `Tests First (RED)` entry asserts telemetry, a query/cache access,
call count, lock/semaphore, private helper, retry/call order, or framework policy
instead of—or in addition to—the desired outcome, stop and request a
plan/test-strategy revision. Also stop when multiple tests duplicate the same
outcome without a distinct acceptance criterion.

Create a todo list (TodoWrite) to track phases. Each plan phase is one todo.

**Phase granularity expectation.** Plans from `my-plan` are sized **one function / one small unit of behavior per phase** — test it in isolation, implement it, return to the checklist, next unit. If a phase in front of you is clearly larger than that (touches many files, bundles several behaviors), treat it as a planning gap: split it into ordered sub-phases yourself before dispatching, or stop and ask for a plan revision. Do not hand an oversized phase to one executor.

## The orchestration loop — one phase at a time

For each unchecked phase, in order:

### 1. Assemble the phase slice

Pull from the plan **only what this phase needs** — do not pass the whole plan or the whole repo. Each executor should run in a small context (target **under ~50k tokens**); a phase that can't fit that is too big and should be split. Note this is a *budget you enforce by scoping*, not a hard cap the harness imposes — so size the slice deliberately. The slice:

- `phase_name`, `phase_overview`
- `red_tests` — the phase's "Tests First (RED)" list
- `behavioral_test_contracts` — the matching test-strategy IDs, public outcomes/stable postconditions, and explicitly prohibited implementation-detail assertions
- `test_design_constraints` — level, fixture ownership, deterministic controls, recovery behavior, and external-boundary double guidance from the strategy
- `green_changes` — the phase's "Changes Required (GREEN)" list
- `success_criteria` — the phase's mechanical success criteria (RED ones first, then GREEN/checks)
- `allowed_paths` — the files/dirs this phase may touch (derive from the change list)
- `verification_commands` — how to run tests/checks in this stack (see the
  retained `verification-commands.md` reference)
- `architectural_constraints` — the plan's constraints relevant to this phase
- `working_context` — cwd, stack, any setup notes

If a phase lacks a "Tests First (RED)" section or matching behavioral test contracts, **stop and ask** — the plan needs updating before this phase can run. TDD is not optional, and a task/checklist assertion is not a behavioral contract.

### 2. Dispatch one executor

Spawn the `implementation-executor` agent with the slice. **One at a time** — never run two executors in parallel; they share the working tree and the plan's phase order encodes dependencies. Let it finish before you do anything else.

### 3. Re-verify independently (you are not the implementer)

When the executor returns its report, **do not take it on faith**. As the reviewer-not-implementer, confirm two things: that the mechanical checks pass, and — the real goal — that the implementation actually **matches the requirements this phase was given**.

1. **Re-run the phase's mechanical `success_criteria`** yourself and read the diff the executor produced.
2. **Check requirements and test-strategy conformance against the slice you handed it.** Read the executor's "Requirements Conformance" and "Test Fidelity" tables, then verify them against the diff: does the code satisfy `phase_overview` and every desired outcome fully? Does each test prove only that outcome, or does it add assertions about telemetry, storage/cache calls, locks, call sequence, private helpers, or framework policy? Is the same outcome duplicated at another layer? Was anything in the brief silently dropped or reinterpreted? Green tests that do not encode the requested outcome—or that freeze its mechanism—do **not** count as done.

- All criteria pass, the diff stays within `allowed_paths`, AND the implementation meets the phase's requirements and behavior-first test strategy → the phase is genuinely done.
- A criterion fails, the diff touched files it shouldn't have, the executor returned `ESCALATE`, OR the work doesn't conform to the requirements (even with green tests) → go to Loop Detection (re-dispatch with a brief that names the specific gap).

Before declaring a Python phase green where it involves a dependency pin, lockfile change, or fresh-install behavior **inside a git worktree**: apply the **Worktree `.venv/bin/*` shebangs** gotcha. A `uv run pytest` can silently run via a sibling worktree's interpreter if the entry-point shebang snapshotted it at venv creation. Check `head -1 .venv/bin/pytest`; if it points outside this worktree, `rm -rf .venv && uv sync` and re-run, or `uv run --no-active python -m pytest ...`.

### 4. Record and advance

On a verified-done phase:
1. Mark the phase's RED, GREEN, and Success-Criteria checkboxes `[x]` in the plan file or workflow ledger.
2. Update the todo to completed.
3. Move to the next phase.

Maintain FORWARD MOMENTUM. Don't re-open finished phases, don't gold-plate, don't let an executor wander beyond its slice.

## Loop Detection (orchestrator-owned)

The executor stops itself after one repeated failure; **you** track failures across attempts. For a given phase:

- **First failure** (criterion fails or executor escalates): diagnose from the report + the diff. If the cause is a too-thin brief (missing path, ambiguous criterion), tighten the slice and re-dispatch **once**.
- **Same check fails a second time** (3rd total across executor + your re-runs): **STOP.** Do not re-dispatch again. Present to the user:
  - What this phase is trying to accomplish
  - What keeps failing + the error output
  - What the executor and you have tried
  - Your best root-cause theory
  - Suggested path forward (often a plan revision)
- **`escalation: phase-too-big`**: the phase exceeded a single executor's reasonable scope. Split it into smaller ordered sub-phases (function-grained) and dispatch those — or, if it can't be cleanly split, stop and ask for a plan revision.

Escalation is efficiency, not failure. Never power through a 3-strike failure.

## Handling Plan Deviations

If reality differs from the plan (reported by the executor or found in your re-verify):
- **Minor**: accept the executor's adaptation, note the deviation in the plan file, continue.
- **Major**: STOP and discuss before proceeding. Indicators: a file the plan assumes exists doesn't; an API changed since planning; the approach can't work for an unanticipated reason; the work needs files outside every phase's `allowed_paths`.

## Completion

When all phases are verified done:
1. Run the full testing strategy from the plan (you run this yourself — it's the holistic gate).
2. Update the plan status to `implemented`.
3. Present a summary: what was done, any deviations, any remaining concerns, and how many phases needed a re-dispatch (a signal for tuning future plan granularity).
4. Suggest running `/implement-review` for the post-implementation review and
   bounded repair loop. Do not enter that loop until every phase and this
   holistic test gate are complete.

In embedded mode, return the compact phase/commit/verification outcome to
`my-workflow`. Do not update its ledger or declare the pipeline complete.

## Guidelines

- **You orchestrate; the executor implements.** Don't write the tests or production code in the main context — dispatch them. Your job is slicing, verifying, and loop control.
- **Tests before code — always**, enforced inside every executor. A phase with no RED tests does not get dispatched.
- One executor at a time; phases are sequential.
- Keep each slice minimal — the executor's context should be small, which is the whole point.
- Do not run raw git commit commands or any outward git action. Each validated
  phase is committed locally through `Skill(commit)` by the executor or this
  runner's recovery path; failed or escalated work remains uncommitted.
- The plan is the WHAT; the executor decides the HOW for its phase, within `allowed_paths` and `architectural_constraints`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The tests are green, the phase is done" | Green tests don't guarantee the code matches the phase's actual requirements — vacuous tests pass too. Always check requirements conformance against the diff, not just criteria output. |
| "The executor said it's done, I trust it" | You are the reviewer, not the implementer's rubber stamp — re-run success criteria and read the diff yourself every time. |
| "This phase is a little bigger than planned, I'll let it ride" | An oversized phase is a planning gap, not a rounding error — split it before dispatch, or the executor's context thins out exactly where it matters. |
| "One more retry will probably fix it" | That's what the loop-detection limit is for. A third failure on the same root cause means stop and escalate, not "try once more." |
| "The deviation is minor, I'll just note it and move on" | Confirm it's actually minor against the stated indicators (missing file, changed API, blocked path) before classifying it — a major deviation dressed up as minor compounds silently across phases. |
| "I'll dispatch two executors to go faster" | Executors share the working tree and phase order encodes dependencies — parallel dispatch risks conflicting edits, not speed. |

## References

Consult the retained skill references while assembling slices:
- `~/.claude/skills/my-implement/references/verification-commands.md` (or
  `~/.agents/skills/my-implement/references/verification-commands.md` under
  Codex) — common verification commands by stack (feeds
  `verification_commands` and your re-verify step).

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them. Pass any phase-relevant gotcha into the executor's slice so it doesn't rediscover it the hard way.
