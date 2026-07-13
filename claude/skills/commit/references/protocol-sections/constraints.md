## Constraints

- **Never commit secrets** — if `.env`, credential files, API keys, or private keys are in the diff, warn and exclude them
- **Never use `git add -A` or `git add .`** — always stage specific files
- **Never skip hooks** — if a pre-commit hook fails, diagnose and fix the issue rather than using `--no-verify`
- **Never amend without warning** — if the previous commit is already pushed, warn about force-push implications before amending
- **Subject line is not the whole message** — a commit that only has a subject line is incomplete. Every commit needs at least a Why section with substance.
- **Why is not How** — "Refactored the auth module" is How. "Auth module was tightly coupled to the HTTP layer, making it untestable" is Why.
- **Ask when unsure** — if a change is ambiguous or you can't determine its purpose from the diff and context, ask for clarification rather than guessing.
