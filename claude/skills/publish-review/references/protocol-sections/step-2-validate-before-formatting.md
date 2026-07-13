## Step 2 - Validate Before Formatting

### Fetch PR Current State

```bash
# Get latest commit SHA; comments must target this.
gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha'

# Get diff to validate line numbers.
gh pr diff {number}

# Get existing comments to validate reply targets. Keep payload filtered.
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate \
  --jq '.[] | {id, path, line, in_reply_to_id, user: .user.login, body: .body[:80]}'
```

If resolution/outdated state matters, use the GraphQL `reviewThreads` query from `~/.claude/rules/pr-cost-control.md` instead of fetching raw REST comments.

### Validate Line Numbers

For every inline comment, confirm `line` appears in PR diff:

1. Find file's diff hunks in `gh pr diff` output.
2. Parse `@@` headers: `@@ -oldStart,oldCount +newStart,newCount @@`.
3. Verify target line is within the hunk, including context lines.
4. If line is not in diff, API will reject comment 422. Adjust to nearest valid line or convert to PR-level comment.

### Validate Reply Targets

For every thread reply:

1. Confirm `comment_id` exists in fetched comments.
2. If target comment is itself a reply (`in_reply_to_id` set), use `in_reply_to_id`; replies must target top-level comments.
3. If comment ID does not exist, warn user and convert to quoted PR-level comment.

### Line Number Rules

- `line` is actual file line number, not diff position.
- `side: "RIGHT"` + `line: 42` = line 42 in new version.
- `side: "LEFT"` + `line: 42` = line 42 in old version.
- Newly added files use `RIGHT`; deleted files use `LEFT`.
- Context lines use `RIGHT` by convention.
- Never use deprecated `position`.

Optional multi-line comments use `start_line` + `line`; both must be within the same diff hunk.
