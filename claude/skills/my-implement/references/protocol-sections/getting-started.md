## Getting Started

If `$ARGUMENTS` contains a path, read that plan. Otherwise, list plans in `~/.claude/thoughts/shared/plans/` and ask the user which to implement.

Read the plan completely. Check for existing `[x]` checkmarks — if resuming, trust completed work and pick up from the first unchecked phase. Only re-verify previous work if something seems off.

Create a todo list (TodoWrite) to track phases. Each plan phase is one todo.

**Phase granularity expectation.** Plans from `my-plan` are sized **one function / one small unit of behavior per phase** — test it in isolation, implement it, return to the checklist, next unit. If a phase in front of you is clearly larger than that (touches many files, bundles several behaviors), treat it as a planning gap: split it into ordered sub-phases yourself before dispatching, or stop and ask for a plan revision. Do not hand an oversized phase to one executor.
