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
