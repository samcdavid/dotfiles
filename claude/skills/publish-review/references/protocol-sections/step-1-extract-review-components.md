## Step 1 — Extract Review Components

Parse the review from the conversation into three categories:

### New Inline Comments
File/line specific findings that should appear as inline review comments in the diff. Each needs:
- `path` — file path relative to repo root
- `line` — the line number in the file (NOT a diff position — see Line Number Rules below)
- `side` — `RIGHT` for added/modified lines (most common), `LEFT` for deleted lines
- `body` — the comment text in markdown

### Thread Replies
Responses to existing review comments. Each needs:
- `comment_id` — the numeric ID of the **top-level** comment in the thread (NOT a reply's ID)
- `body` — the reply text

### Review Body
The top-level review summary. Includes:
- `body` — overall review markdown text
- `event` — one of `APPROVE`, `REQUEST_CHANGES`, or `COMMENT`
