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
