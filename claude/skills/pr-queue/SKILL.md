---
name: pr-queue
description: "Table of open PRs in the current repo that are waiting on my review, with size stats; refreshable and filterable."
when_to_use: "Use when the user asks what PRs are waiting on their review, what's in their review queue, or to refresh that list."
effort: xhigh
---

Use `gh` to get the open, non-draft PRs in the current repo where my review is requested:

```sh
gh pr list --search "review-requested:@me draft:false" --state open \
  --json number,title,author,changedFiles,additions,deletions,isDraft,url
```

Also drop any row whose `isDraft` is true. Include drafts only when I ask
("include drafts"); then mark each one 📝 in the table.

Show a table, newest first:

| # | Title | Author | Files | +/− |
|---|---|---|---|---|

Under it, one line naming the largest PRs and the small ones (under 100 edits).

Follow-ups:
- **"Links for ones under N edits/files"** — a bullet list of `[#N](url)` links,
  each with its count and title. "Edits" means additions + deletions. Say so,
  and note if another reading would change the list.
- **"Update the table" / "I reviewed those"** — re-query. Drop PRs no longer
  requesting my review, mark new ones 🆕, and say what changed since last time.
  A PR that moved from draft to ready counts as new.
- If a filter uses the last pull rather than a fresh query, say so.
