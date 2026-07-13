## Getting Started

Determine scope:
- If `$ARGUMENTS` contains a PR number or URL → audit that PR
- If `$ARGUMENTS` contains a Linear ticket ID or URL → audit changes for that ticket
- If empty → ask the user what to audit

A requirements audit requires a spec to audit against. If neither a PR description nor a Linear ticket provides acceptance criteria, ask the user for the source of truth.
