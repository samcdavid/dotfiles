# Final Report

Load this when completing `my-workflow`.

Report:

- Task and entry point.
- Stages run and skipped with reasons.
- Artifacts produced.
- Behavior-first test strategy and its implementation handoff.
- User decisions.
- Factual assumptions.
- Cross-workflow coordination — sibling ledgers/issues checked on the same Linear project (or "no Linear issue"), any overlap found, and how it was resolved.
- Files changed.
- Tests and validation commands.
- `implement-review` terminal status, review-clean flag, every review pass, and
  the fix commits each produced.
- When migrations were in scope: the migration-history matrix, validation result for each history, release-health evidence, and any explicit override of a blocked gate.
- Surviving findings and root-cause theory when `implement-review` is `blocked`
  or `cap_reached`; do not present either state as completion.
- Suggested next command.

End by stating that no git outward actions were taken unless explicitly requested.
