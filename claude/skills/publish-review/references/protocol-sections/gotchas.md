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
