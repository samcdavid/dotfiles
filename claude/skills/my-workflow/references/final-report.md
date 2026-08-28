# Final Report

Load this when completing `my-workflow`.

Report:

- Task, route, and canonical ledger path/version.
- Planning conversation decisions and focused deep dives used.
- Synchronized requirements, architecture, behavior-first test strategy,
  observability/evaluation, migration/operations, and implementation phases.
- User decisions.
- Factual assumptions.
- Issue context scope and refresh — linked issues plus milestone issues, or
  linked issues plus project issues when no milestone exists, or linked-only
  when no project exists; any overlap and resolution.
- Files changed.
- Tests and validation commands.
- `my-implement` completion status, every phase commit, and holistic test gate.
- `implement-review` terminal status, review-clean flag, every post-implementation
  review pass, and the repair commits each produced.
- When migrations were in scope: the migration-history matrix, validation result for each history, release-health evidence, and any explicit override of a blocked gate.
- Surviving findings and root-cause theory when `implement-review` is `blocked`
  or `cap_reached`; do not present either state as completion.
- Suggested next command.

End by stating that no git outward actions were taken unless explicitly requested.
