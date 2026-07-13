# PR Mode

Load for GitHub PR review.

Hard constraints:

- Do not check out, switch to, or fetch PRs into named local branches.
- Do not read changed PR files from disk as PR contents.
- Use `gh pr diff <number>` as diff source truth.
- Fetch full PR HEAD contents with `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` when needed.
- Fetch existing inline comments, reviews, issue comments, and threads using `pr-cost-control.md` filtered payloads.

Every subagent prompt in PR mode must receive the same constraints and PR HEAD SHA.
