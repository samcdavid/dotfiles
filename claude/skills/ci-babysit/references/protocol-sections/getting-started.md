## Getting Started

Determine what to monitor:
- If `$ARGUMENTS` contains a PR number or URL → monitor that PR's pipeline
- If `$ARGUMENTS` contains a CircleCI pipeline/workflow URL → monitor that directly
- If `$ARGUMENTS` is empty → detect from the current branch:

```bash
git branch --show-current
git remote get-url origin
```

Then use `gh pr view` to find the PR for the current branch. If no PR exists, ask whether to monitor the branch pipeline directly.
