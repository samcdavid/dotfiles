## Step 1 — Gather All Feedback

Read `~/.claude/rules/pr-cost-control.md` first. Fetch only fields needed build feedback index.

```bash
gh pr view <number> --json number,title,body,headRefOid,baseRefName,headRefName,files,reviewRequests,reviews \
  --jq '{number,title,body,headRefOid,baseRefName,headRefName,files:[.files[] | {path,additions,deletions}],reviewRequests,reviews:[.reviews[] | {state,author:.author.login,body,submittedAt}]}'
gh pr diff <number>
```

Use the GraphQL `reviewThreads` query in `pr-cost-control.md` primary source inline comments, resolved state, outdated state. Use filtered REST fallbacks from that rule only for review bodies or issue-level comments not covered by threads.

Do not ingest raw `gh api` review/comment payloads. If filtered response misses required field, fetch that field explicitly.

Build a structured index of every comment, organized by:

- **Who** said it
- **Where** (file:line, or general PR comment)
- **What** they said
- **Comment ID** — the numeric ID from the API (needed for thread replies)
- **Comment type** — `review_comment` (inline on a file:line), `review_body` (top-level review submission), or `issue_comment` (general PR conversation)
- **Status** — is it resolved, pending, or part of an ongoing thread?
- **Has it already been addressed?** Check if there's a reply with a commit SHA or a "done" acknowledgment.

This index determines HOW you'll reply later:

- `review_comment` → reply in-thread using `in_reply_to` with the comment ID
- `review_body` → reply as a new issue comment quoting the relevant text
- `issue_comment` → reply as a new issue comment quoting the relevant text

Skip comments that are already resolved or addressed. Focus only on **pending, unresolved feedback**.

### Requirements Traceability Baseline

If the PR description links to a Linear ticket (e.g. `ENG-123`, `Fixes ENG-123`, Linear URL), fetch it using the Linear MCP tools. Extract the title, description, acceptance criteria, and sub-issues.

Build a **requirements map**: for each acceptance criterion, which file(s) and change(s) in the current PR diff address it. You will use this map in the self-audit (Step 10) to verify that your fixes don't accidentally remove coverage for an original requirement.
