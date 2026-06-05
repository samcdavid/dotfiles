---
model: sonnet
name: quick-implement
description: Execute a quick-plan phase by phase. Dispatches TDD phases to quick-implement-agent using RED → GREEN → VALIDATE; dispatches direct-edit phases to quick-implement-agent for targeted function-level edits. Owns loop detection. Uses the same format/lint/test SubagentStop hook as my-implement.
---

# Quick Implement

Execute a `quick-plan` file phase by phase, dispatching each to a fresh `quick-implement-agent`. This is the lighter counterpart to `my-implement` — same orchestration discipline (one agent at a time, independent re-verify, loop detection), but handles both TDD phases and direct-edit phases.

Why this shape: each phase runs in a small, fresh context. The orchestrator re-verifies independently (the implementer is never its own reviewer), and the SubagentStop hook runs format + lint + changed tests automatically on every agent stop.

## Getting Started

If `$ARGUMENTS` contains a path, read that plan. Otherwise list plans in `~/.claude/thoughts/shared/plans/` matching the `quick_` prefix and ask which to execute.

Read the plan completely. Check for `[x]` checkmarks — if resuming, pick up from the first unchecked phase. Trust completed work; only re-verify if something seems off.

Create a TodoWrite list: one todo per phase.

## The Orchestration Loop — one phase at a time

For each unchecked phase, in order:

### 1. Identify the phase type

Read the phase block. If it has a `Tests First (RED)` section → **TDD phase**. If it has an `Edit Target` section → **DIRECT EDIT phase**.

### 2. Assemble the phase slice

Pull only what this phase needs. Keep the agent's context small (target under ~30k tokens):

**For TDD phases:**
- `phase_name`, `phase_overview`
- `phase_type: "tdd"`
- `red_tests` — list of test paths + what each asserts
- `green_changes` — list of production changes (paths + descriptions)
- `success_criteria` — mechanical, RED first then GREEN
- `allowed_paths` — derived from the plan's change list
- `verification_commands` — how to run tests in this stack (see `my-implement`'s `references/verification-commands.md`)
- `architectural_constraints` — from the plan's "What We're NOT Doing" and any stack rules
- `working_context` — cwd, stack, any gotchas relevant to this phase

If a TDD phase has no `red_tests`, STOP — the plan needs a revision before this phase can run.

**For DIRECT EDIT phases:**
- `phase_name`, `phase_overview`
- `phase_type: "direct_edit"`
- `edit_target` — file path + function name + line range
- `edit_description` — full description of the edit (the agent has no prior context)
- `success_criteria` — grep/lint/test checks that confirm the edit is correct and regressions are absent
- `allowed_paths` — the file(s) this phase may touch
- `verification_commands` — lint + relevant test command
- `architectural_constraints` — any boundaries that apply
- `working_context` — cwd, stack, any gotchas

### 3. Dispatch ONE `quick-implement-agent`

One at a time — phases are sequential, they share the working tree. Let it finish before doing anything else.

The SubagentStop hook fires automatically: format + lint + changed test files must pass before control returns. A green report that hasn't cleared the hook has not cleared the gate.

### 4. Re-verify independently (you are not the implementer)

When the agent returns its report, do not take it on faith:

1. **Re-run the phase's success_criteria** yourself and read the diff.
2. **For TDD phases:** Check requirements conformance — does the code satisfy `phase_overview`? Do the tests genuinely exercise the required behavior (would they fail if the behavior were wrong)? Was anything quietly dropped or reinterpreted?
3. **For DIRECT EDIT phases:** Read the diff. Does the edit match `edit_description`? Did any behavior change that shouldn't have? Did the agent stay within `allowed_paths`?

All criteria pass, diff in-bounds, requirements met → phase is done. Otherwise → Loop Detection.

### 5. Record and advance

Mark the phase's checkboxes `[x]` in the plan file and mark the todo completed. Move to the next phase.

Maintain forward momentum: don't re-open finished phases, don't gold-plate.

## Loop Detection (orchestrator-owned)

- **First failure** (criterion fails or agent escalates): diagnose from report + diff. If the brief was thin (missing path, ambiguous description), tighten the slice and re-dispatch **once**.
- **Same check fails a second time** (3rd total across agent + your re-runs): **STOP.** Present to the user: what the phase was trying to do, what keeps failing (+ error output), what's been tried, your root-cause theory, suggested path forward.
- **`escalation: phase-too-big`**: split the phase into smaller ordered phases and dispatch those, or ask for a plan revision.

Escalation is efficiency, not failure. Never power through a 3-strike failure.

## Handling Plan Deviations

- **Minor**: accept the agent's adaptation, note the deviation in the plan file, continue.
- **Major** (a file the plan assumed doesn't exist, an API changed, the fix needs files outside `allowed_paths`): STOP and discuss before proceeding.

## Completion

When all phases are verified done:
1. Run the full relevant test suite yourself — the holistic gate.
2. Update the plan status to `implemented`.
3. Present a summary: phases done, any deviations, re-dispatches needed.
4. The caller (`implement-conversation`) proceeds to `my-review`.

## References

Consult `my-implement`'s `references/verification-commands.md` for per-stack `verification_commands` when assembling slices.
