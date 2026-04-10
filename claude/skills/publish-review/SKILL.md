---
name: publish-review
description: Publish a PR review from the current session to GitHub. Formats inline comments, thread replies, and the review body, then posts via `gh api`. Handles line number mapping, reply targeting, and markdown formatting. Manual invocation only.
disable-model-invocation: true
---

# Publish PR Review to GitHub

Publishes a PR review that has been written in the current conversation to GitHub. Supports inline file comments, thread replies to existing comments, and a top-level review body.

## Prerequisites

A PR review must already exist in the conversation context (typically from `/my-review`). This review should include:
- A review summary/body
- File/line specific comments (optional but recommended)
- A review decision (APPROVE, REQUEST_CHANGES, or COMMENT)

## Getting Started

Determine the PR:
- If `$ARGUMENTS` contains a PR number or URL, use that.
- Otherwise, check `gh pr status` for the current branch's PR.
- If neither works, ask the user.

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

## Step 2 — Validate Before Formatting

### Fetch the PR's current state

```bash
# Get the latest commit SHA — comments must target this
gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha'

# Get the diff to validate line numbers
gh pr diff {number}

# Get existing comments to validate reply targets
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate \
  --jq '.[] | {id, path, line, in_reply_to_id, user: .user.login, body: .body[:80]}'
```

### Validate line numbers

For every inline comment, confirm the `line` number appears in the PR diff for that file:

1. Find the file's diff hunks in `gh pr diff` output.
2. Parse `@@` headers: `@@ -oldStart,oldCount +newStart,newCount @@`
3. Verify the target line is within a hunk (including context lines).
4. If the line is NOT in the diff, the API will reject the comment with a 422. Either:
   - Adjust to the nearest line that IS in the diff, or
   - Convert to a general PR comment instead

### Validate reply targets

For every thread reply:

1. Confirm the `comment_id` exists in the fetched comments.
2. If the target comment is itself a reply (has `in_reply_to_id`), use the `in_reply_to_id` instead — replies must target the **top-level** comment.
3. If the comment ID doesn't exist, warn the user and convert to a quoted PR-level comment.

### Line Number Rules

The `line` field refers to the **actual file line number**, not a diff position offset:

- `side: "RIGHT"` + `line: 42` = line 42 in the **new version** of the file (head branch)
- `side: "LEFT"` + `line: 42` = line 42 in the **old version** of the file (base branch)
- For newly added files: all lines are `RIGHT`
- For deleted files: all lines are `LEFT`
- For context lines (unchanged): use `RIGHT` by convention
- The `position` field is **deprecated** — never use it

**Multi-line comments** (optional): use `start_line` + `line` to highlight a range:
```json
{
  "path": "src/app.ts",
  "start_line": 10,
  "start_side": "RIGHT",
  "line": 15,
  "side": "RIGHT",
  "body": "This block should be extracted."
}
```
Both `start_line` and `line` must be within the same diff hunk.

## Step 3 — Format the Payloads

### Main review payload (JSON file)

Build a JSON file for the review. All inline comments must be included atomically — you cannot add comments to a review incrementally.

```json
{
  "commit_id": "<latest HEAD SHA from Step 2>",
  "body": "Overall review summary in markdown",
  "event": "APPROVE|REQUEST_CHANGES|COMMENT",
  "comments": [
    {
      "path": "relative/path/to/file.ext",
      "line": 42,
      "side": "RIGHT",
      "body": "Comment text in markdown"
    }
  ]
}
```

**Formatting the `body` and comment text:**
- Newlines in JSON strings: use `\n`
- Backticks: no escaping needed inside JSON strings
- Double quotes: escape as `\"`
- Code blocks: use triple backticks with language identifier
- Maximum comment body length: 65,536 characters

**AI Agent instructions block** — for inline comments that include actionable fix suggestions, append a collapsible details block:

```markdown
Human-readable review comment here.

<details>
<summary>Instructions for AI Agents</summary>

Specific, actionable instructions that an AI coding agent can follow to implement the change.

</details>
```

Rules for the AI Agent instructions block:
- Only include on inline comments (those with `path` and `line`) that have a concrete fix suggestion
- Do NOT include on the overall review `body`
- Do NOT include on thread replies
- Preserve the human-readable comment exactly as written above the `<details>` block
- Ensure blank lines before `<details>` and after `</details>` for correct markdown rendering

### Thread reply payloads

Thread replies are posted separately, one per reply. No JSON file needed:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  -f body="Reply text"
```

### PR-level comment payloads (fallback)

For comments that can't be posted inline (line not in diff) or replies where the target comment no longer exists:
```bash
gh api repos/{owner}/{repo}/issues/{number}/comments \
  -f body="> Quoted original text

Response text"
```

## Step 4 — Present for Confirmation

**Always show the user the complete review before publishing.** Format it clearly:

```markdown
## Review to Publish — PR #{number}

### Review Body ({event})
{body text}

### Inline Comments ({N})
1. `path/to/file.ext:LINE` (RIGHT)
   {comment text, truncated to ~100 chars}

### Thread Replies ({N})
1. Reply to comment {id} by {user} on `path:line`:
   > {original comment, truncated}
   {reply text}

### PR-Level Comments ({N}) [fallback]
1. Quoting {user}:
   > {quoted text}
   {response text}

Publish this review? (y/n)
```

Do NOT publish without user confirmation.

## Step 5 — Publish

### Publishing order

1. **Main review first** — this creates all inline comments atomically
2. **Thread replies second** — these respond to existing conversations
3. **PR-level comments last** — these are the least targeted

### Publish the main review

Write the JSON payload to a temp file and post:

```bash
REVIEW_FILE=$(mktemp)
cat > "$REVIEW_FILE" <<'JSONEOF'
{review JSON here}
JSONEOF

gh api repos/{owner}/{repo}/pulls/{number}/reviews --input "$REVIEW_FILE"
rm "$REVIEW_FILE"
```

If the review has no inline comments and the event is `APPROVE`:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  -f body="Review summary" \
  -f event="APPROVE" \
  -f commit_id="<SHA>"
```

### Publish thread replies

One request per reply:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  -f body="Reply text"
```

If a reply fails (404 — comment deleted or ID invalid):
1. Report the failure to the user
2. Fall back to a PR-level comment quoting the original
3. Continue with remaining replies

### Publish PR-level comments

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments \
  -f body="> Quoted text

Response"
```

### Error handling

| Error | Cause | Recovery |
|-------|-------|----------|
| 422 on review | Line not in diff, invalid path, or malformed JSON | Report which comment failed. Convert to PR-level comment. |
| 404 on thread reply | Comment ID doesn't exist | Fall back to PR-level quoted comment. |
| 403 | Insufficient permissions or locked PR | Stop and report to user. |
| 422 "was submitted too quickly" | Secondary rate limit | Wait 60 seconds and retry once. |
| 409 | Conflict (rare) | Retry once. |

### Rate limiting

GitHub enforces:
- 80 content-creating requests per minute (secondary limit)
- 500 content-creating requests per hour

Batch inline comments into the main review (single request) rather than posting them individually. Thread replies must be individual requests — if there are many (>20), add a 1-second delay between batches of 10.

## Step 6 — Report Result

After publishing:

```markdown
## Published

### Review
- Event: {APPROVE/REQUEST_CHANGES/COMMENT}
- URL: {link to review}
- Inline comments: {N} posted

### Thread Replies
- {N} posted successfully
- {N} failed (fell back to PR-level comments)

### PR-Level Comments
- {N} posted

[Link to PR conversation]
```

## Gotchas

### Critical
- **Use `line`, not `position`.** The `position` field is deprecated. `line` is the actual file line number on the specified `side`.
- **`line` must be in the diff.** The API rejects comments on lines not shown in the diff (including context). Always validate against `gh pr diff` first.
- **All inline comments are atomic.** You cannot add comments to a review after creation. Build the entire `comments` array before posting.
- **Replies target top-level comments only.** If a comment has `in_reply_to_id`, use that ID instead — replying to a reply doesn't work.
- **One pending review per user per PR.** If you omit `event`, a pending review is created. Creating a second will fail. Always include `event` to submit immediately.
- **`--input` for complex payloads.** The `-f` flag cannot build the nested `comments` array reliably. Always use `--input` with a temp file or stdin for reviews with inline comments.
- **Include `commit_id`.** Always fetch and include the latest `head.sha`. Comments against stale commits may render as "outdated" on GitHub.

### Formatting
- **JSON string newlines**: use `\n`, not literal newlines
- **65,536 character limit** per comment body
- **Blank lines around `<details>` blocks** — required for GitHub markdown rendering
- **Heredoc quoting**: use `<<'EOF'` (single-quoted) to prevent shell interpolation of backticks and `$` in review text
