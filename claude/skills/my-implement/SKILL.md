---
name: my-implement
description: Execute an approved implementation plan phase-by-phase with continuous verification. Uses reasoning sandwich (think-act-verify) and loop detection to maintain quality and forward momentum.
disable-model-invocation: true
---

# Implement Plan

Execute an approved technical plan with continuous verification. Every change is verified before moving forward. If you get stuck, you escalate — you don't spin.

## Getting Started

If `$ARGUMENTS` contains a path, read that plan. Otherwise, list plans in `~/.claude/thoughts/shared/plans/` and ask the user which to implement.

Read the plan completely. Check for existing `[x]` checkmarks — if resuming, trust completed work and pick up from the first unchecked item. Only re-verify previous work if something seems off.

Read ALL files mentioned in the plan FULLY (no limit/offset).

Create a todo list (TodoWrite) to track implementation progress.

## Implementation Loop

For each phase, for each change:

### 1. THINK (Reasoning Sandwich — Before)
Before making any code change, state:
- What you're about to change and why
- What the expected outcome is
- What could go wrong

### 2. ACT
Make the change. Follow the plan's intent while adapting to codebase reality — the plan is a guide, not a straitjacket. If the code has evolved since planning, adapt intelligently.

### 3. VERIFY (Reasoning Sandwich — After)
After each change:
- Run the relevant success criteria for this phase
- Check that nothing unrelated broke
- Verify the change matches your stated intent from step 1

If verification passes: update the plan checkbox to `[x]`, update todos, continue.

If verification fails: attempt to fix (max 2 attempts on the same issue). If still failing, see Loop Detection below.

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
1. Run ALL success criteria for the completed phase
2. Verify no architectural constraints were violated
3. Update the plan file — mark phase checkboxes as `[x]`
4. Update todos

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

- Maintain FORWARD MOMENTUM — don't gold-plate or refactor beyond the plan
- Keep the end goal in mind, not just the current step
- Commit meaningful chunks of work as you go (don't wait until everything is done)
- If you discover something important the plan missed, note it — but stay focused on execution
- The plan is the WHAT. You decide the HOW based on current codebase state.

## References

This skill has reference files in `references/` — consult them during implementation:
- `references/verification-commands.md` — common verification commands by stack

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
