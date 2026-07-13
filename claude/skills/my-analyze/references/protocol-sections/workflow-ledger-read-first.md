## Workflow Ledger (read first)

This skill runs both standalone and as a stage inside `/my-workflow`. Before anything else, look for the issue's workflow ledger:

- Search `~/.claude/thoughts/shared/workflows/` for a ledger matching this task (by Linear ID, ticket slug, or topic).
- **If one exists, read it fully.** It is the plan-of-record for the whole issue: it lists which stages have run and the artifacts they produced (with paths). Use it to discover exactly which research, spec, and plan to compare — don't re-hunt for them — and honor the decisions it already records when judging whether a deviation is intentional.
- **When you finish, if a ledger exists, append the analysis report path and any decisions reached while resolving issues** to it.
- If no ledger exists, proceed without one — do not create a workflow ledger yourself (that is `/my-workflow`'s job).
