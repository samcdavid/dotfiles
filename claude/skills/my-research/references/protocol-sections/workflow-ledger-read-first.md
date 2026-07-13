## Workflow Ledger (read first)

This skill runs both standalone and as a stage inside `/my-workflow`. Before anything else, look for the issue's workflow ledger:

- Search `~/.claude/thoughts/shared/workflows/` for a ledger matching this task (by Linear ID, ticket slug, or topic).
- **If one exists, read it fully.** It is the plan-of-record for the whole issue: the task framing, which stages have run, the artifacts they produced (with paths), and the running "Autonomous decisions & assumptions" list. Treat it as authoritative shared context — never re-ask or re-derive what it already settles, and prefer its artifact paths over re-discovering them.
- **When you finish, if a ledger exists, append this stage's outcome to it**: the research doc path and any assumptions/decisions recorded here. This keeps a single-skill run consistent with the overall workflow.
- If no ledger exists, proceed without one — do not create a workflow ledger yourself (that is `/my-workflow`'s job).
