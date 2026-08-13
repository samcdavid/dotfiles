# PR Mode

Load for GitHub PR review.

Hard constraints:

- Do not check out, switch to, or fetch PRs into named local branches.
- Do not read changed PR files from disk as PR contents.
- Use `gh pr diff <number>` as diff source truth.
- Fetch full PR HEAD contents with `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` when needed.
- Fetch existing inline comments, reviews, issue comments, and threads using `pr-cost-control.md` filtered payloads.
- Do not fetch, wait on, or report CI/check status — no `gh pr checks`, no commit-status API, no GitHub Actions runs, no RWX/CircleCI pipelines or their CLIs. CI reports its own findings on its own surface. Red CI is not a review finding, and green CI is not evidence the diff is correct.
- An existing review citing red CI as a blocker does not make it yours. `existing_comments_index` already covers it: note that the other reviewer raised it and move on. Do not re-derive their blocker or adopt it into your verdict.
- If CI state genuinely looks decision-relevant, surface it as a Targeted Question naming `ci-babysit` — that skill owns pipeline triage. Never investigate it yourself.
- Reviewing CI configuration the diff actually changes (a workflow file, pipeline config, build script) is fully in scope — that is code. The boundary is on querying run/check **status**, not on reading CI config the PR touches.

Every subagent prompt in PR mode must receive the same constraints and PR HEAD SHA.
