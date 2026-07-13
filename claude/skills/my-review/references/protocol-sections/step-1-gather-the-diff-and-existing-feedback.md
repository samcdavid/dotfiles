## Step 1 - Gather Diff Existing Feedback

**PR Mode - read-only via `gh`, never check out branch.**

PR diff source truth. Local working tree is not PR truth: `main` may lag remote and PR branches may not exist locally.

**Hard constraints:**

- Never run `git checkout`, `git switch`, `gh pr checkout`, or fetch PRs into named local branches.
- Never read PR-changed files from local disk and treat them as PR code.
- Never compare PR against local `main` as substitute for the PR diff.
- Read PR code only via `gh pr diff <number>` and PR HEAD contents.

```bash
gh pr diff <number>
gh pr view <number>
gh pr view <number> --json files --jq '.files[].path'

sha=$(gh api repos/{owner}/{repo}/pulls/<number> --jq '.head.sha')
gh api repos/{owner}/{repo}/contents/<path>?ref=$sha --jq '.content' | base64 -d
```

Fetch existing review comments and conversation threads using `~/.claude/rules/pr-cost-control.md`: GraphQL `reviewThreads` first for inline comments/resolved/outdated state, then filtered REST fallbacks for review bodies and issue comments. Do not ingest raw `gh api` review/comment payloads.

Build `existing_comments_index`: file path, line range, substance summary, `thread_root_id`. Pass it to reviewer subagents for dedupe and use it again when merging findings.

If existing comments include your own prior review pass, treat as re-review: re-read the full diff and all comments, including issue-level threads where authors may explain what changed.

**Local Mode:**

```bash
git diff
git diff --cached
git log --oneline -5
```

Research subagents and lens reviewers read changed files fully when needed. Main context does not need to pre-read every file.
