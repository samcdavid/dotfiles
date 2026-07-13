## Getting Started

Determine context from `$ARGUMENTS`:
- If a test plan was just produced in this conversation, use it
- If `$ARGUMENTS` contains a PR number, use it for GIF storage and posting
- If no test plan exists in context, ask the user to provide one or run `my-test-plan` first
- If the PR number is not known, ask for it

Confirm with the user:
1. The app is running locally and accessible in Chrome
2. Any required test data or state is set up (per the plan's prerequisites)
