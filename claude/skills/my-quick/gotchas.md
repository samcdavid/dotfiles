# Gotchas

## Empty invocation can carry intent from the active conversation

- **Trigger:** The user invokes `$my-quick` without a written change request, but the active conversation or workspace supplies the task context.
- **Wrong behavior:** Treat the empty argument as an automatic blocker and ask what to change.
- **Correct behavior:** Infer the bounded task from available context, state the one-sentence interpretation and assumptions, then ask only for the skill's required confirmation before researching or editing. Ask for a task only when no reliable context exists.
- **Why it matters:** Invoking the skill is a request to begin its workflow; redundant intake makes it feel as though the invocation was ignored.

## Branch issue is the default task context

- **Trigger:** The user invokes `$my-quick` with no task text and the current branch name contains a Linear issue key.
- **Wrong behavior:** Inspect only the working tree, conclude there is no task, and ask what to change.
- **Correct behavior:** Look up the Linear issue identified by the branch (for example, `ena-591`), use its title and description as the implementation request, and begin the skill's normal intake from that context.
- **Why it matters:** Branches are normally created for a specific issue; ignoring that association discards the most reliable task context available.
