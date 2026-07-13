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
