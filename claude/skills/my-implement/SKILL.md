---
name: my-implement
description: Execute an approved implementation plan phase-by-phase using mandatory red/green/refactor TDD. Writes failing tests first, then minimum production code to pass, with loop detection to maintain forward momentum.
disable-model-invocation: true
---

# Implement Plan

Execute an approved technical plan with continuous verification. Every change is verified before moving forward. If you get stuck, you escalate — you don't spin.

## Getting Started

If `$ARGUMENTS` contains a path, read that plan. Otherwise, list plans in `~/.claude/thoughts/shared/plans/` and ask the user which to implement.

Read the plan completely. Check for existing `[x]` checkmarks — if resuming, trust completed work and pick up from the first unchecked item. Only re-verify previous work if something seems off.

Read ALL files mentioned in the plan FULLY (no limit/offset).

Create a todo list (TodoWrite) to track implementation progress.

## Implementation Loop — Red/Green/Refactor

TDD is mandatory. For each phase, follow this cycle strictly:

### 1. RED — Write the Failing Test

Before writing ANY production code for this phase:

1. **State intent**: What behavior are you testing and why?
2. **Write the test(s)** defined in the plan's "Tests First (RED)" section
3. **Run the test(s)** — they MUST FAIL
   - If the test passes immediately, it's not testing new behavior. Rewrite it or investigate why.
   - If the test errors (won't compile/import), fix the test scaffolding only — do NOT write production code yet.
4. **Confirm RED**: You now have a failing test that describes the desired behavior.

Update the plan's RED checkboxes to `[x]`.

**HARD RULE**: Do not proceed to GREEN until you have a test that fails for the RIGHT reason (missing behavior, not a syntax error).

### 2. GREEN — Make It Pass

1. **Write the minimum production code** to make the failing test(s) pass
2. Follow the plan's "Changes Required (GREEN)" section as a guide, adapting to codebase reality
3. **Run the test(s)** — they MUST PASS
4. **Run the full phase test suite** — nothing unrelated should break

If tests pass: update the plan's GREEN checkboxes to `[x]`, update todos.

If tests fail: attempt to fix (max 2 attempts on the same issue). If still failing, see Loop Detection below.

### 3. REFACTOR (Optional)

If the plan identifies refactor opportunities, or you see clear structural improvements:

1. **Refactor** — improve code structure without changing behavior
2. **Run tests again** — they must still pass. If any test fails after refactoring, you changed behavior — revert and try again.

Skip this step if there's nothing to clean up. Don't gold-plate.

### Repeat

Move to the next set of tests/changes within the phase, or to the next phase.

## Loop Detection

Track repeated failures. If the SAME check fails 3 times across attempts:

**STOP.** Present to the user:
- What you're trying to accomplish
- What keeps failing and the error output
- What you've tried so far
- Your best theory on the root cause
- Suggested path forward (may require plan revision)

Do NOT keep retrying the same approach. Escalation is not failure — it's efficiency.

## Phase Transitions

Before moving to the next phase:
1. Confirm ALL RED checkboxes are marked — every planned test was written and failed first
2. Confirm ALL GREEN checkboxes are marked — every test now passes
3. Run ALL success criteria for the completed phase
4. Verify no architectural constraints were violated
5. Update the plan file — mark phase checkboxes as `[x]`
6. Update todos

Only proceed when the current phase is fully verified.

## Handling Plan Deviations

If reality differs from the plan:
- **Minor**: Adapt and note the deviation in the plan file
- **Major**: STOP and discuss with the user before proceeding. The plan may need revision.

Indicators of a major deviation:
- A file the plan assumes exists doesn't exist
- An API or interface has changed since planning
- The approach described won't work for a reason not anticipated
- You'd need to modify files NOT listed in the plan

## Completion

When all phases are complete:
1. Run the full testing strategy from the plan
2. Update the plan status to `implemented`
3. Present a summary: what was done, any deviations from plan, any remaining concerns
4. Suggest running `/validate` for a thorough post-implementation check

## Guidelines

- **Tests before code — always.** Never write production code without a failing test. This is not negotiable.
- Maintain FORWARD MOMENTUM — don't gold-plate or refactor beyond the plan
- Keep the end goal in mind, not just the current step
- Commit meaningful chunks of work as you go (don't wait until everything is done)
- If you discover something important the plan missed, note it — but stay focused on execution
- The plan is the WHAT. You decide the HOW based on current codebase state.
- If a plan phase lacks a "Tests First (RED)" section, stop and ask the user — the plan needs updating before implementation can proceed.

## References

This skill has reference files in `references/` — consult them during implementation:
- `references/verification-commands.md` — common verification commands by stack

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
