## Workflow Ledger (read first)

This skill runs both standalone and as a stage inside `/my-workflow`. Before anything else, look for the issue's workflow ledger:

- Search `~/.claude/thoughts/shared/workflows/` for a ledger matching this task (by Linear ID, ticket slug, or topic).
- **If one exists, read it fully.** It is the plan-of-record for the whole issue: the task framing, which stages have run, the artifacts they produced (with paths — especially the spec being clarified), and the running "Autonomous decisions & assumptions" list. Treat it as authoritative shared context — an ambiguity the ledger already resolves is not an ambiguity; drop it.
- **When you finish, if a ledger exists, append the resolved blocking issues to it** as decisions so the next stage doesn't reopen them.
- If no ledger exists, proceed without one — do not create a workflow ledger yourself (that is `/my-workflow`'s job).
