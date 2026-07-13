## Getting Started

Determine what to compare:
- If `$ARGUMENTS` lists specific file paths → use those
- If `$ARGUMENTS` names a feature or topic → search `~/.claude/thoughts/shared/plans/` and `~/.claude/thoughts/shared/research/` for related artifacts
- If empty → use the workflow ledger to identify this issue's artifacts; otherwise list recent artifacts from both directories and propose the most likely set rather than asking blankly.

You need at least two artifacts to compare. If only one exists, tell the user and suggest running `/my-clarify` on it instead.
