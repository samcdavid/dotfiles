## Getting Started

Determine scope:
- If `$ARGUMENTS` contains a PR number → audit that PR's changes
- If `$ARGUMENTS` contains file paths → audit those files and their callers
- If `$ARGUMENTS` names a feature or area → discover and audit all related code
- If empty → ask the user what to audit
