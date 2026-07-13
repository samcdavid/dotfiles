## Getting Started

Determine what to clarify:
- If `$ARGUMENTS` contains a path → read that file
- If `$ARGUMENTS` contains a Linear issue ID → fetch the issue
- If `$ARGUMENTS` contains a URL → fetch and extract
- If empty → check the workflow ledger and `~/.claude/thoughts/shared/research/` and `~/.claude/thoughts/shared/plans/` for recent artifacts; infer the most likely document from context and propose it rather than asking blankly. Only ask which to clarify when context is genuinely ambiguous.

Identify the document type (spec or research) — the analysis adapts accordingly.
