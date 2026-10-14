---
name: pr-queue
description: "Table of open PRs in the current repo that are waiting on my review, with size stats; refreshable and filterable."
effort: xhigh
---

Use `gh` to get the open, non-draft PRs in the current repo where my review is requested:

```sh
gh pr list --search "review-requested:@me" --state open \
  --json number,title,author,changedFiles,additions,deletions,isDraft,url
```

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
- If a filter uses the last pull rather than a fresh query, say so.
