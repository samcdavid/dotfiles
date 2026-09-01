# Review publication protocol

Use this procedure after the user explicitly asks to publish a prepared PR
review. The calling conversation owns review judgment; this session only
validates GitHub anchors and executes the supplied text.

Write a temporary plain-text manifest containing exactly:

```text
PR: <number or URL>
EXPECTED_HEAD_SHA: <optional SHA from the prepared review>
EVENT: APPROVE | REQUEST_CHANGES | COMMENT

REVIEW_BODY:
<prepared body>

INLINE_COMMENTS:
- path: relative/file.ext
  line: 42
  side: RIGHT
  body: <prepared comment>

THREAD_REPLIES:
- comment_id: 12345
  body: <prepared reply>
```

Omit empty sections. Do not add findings, suggestions, AI-agent instructions,
or a fallback PR-level comment for a new inline finding.

From the repository root, read the manifest and use `gh api` directly to fetch
the current PR head, aggregate diff, and filtered review-thread data. Reject the
entire publication if `EXPECTED_HEAD_SHA` is stale or an inline comment is not
anchored in the aggregate diff. Deduplicate exact existing comments and
normalize replies to their top-level comment. Do not rewrite, add, move, or turn
an invalid new inline finding into a PR-level comment. Submit the review
atomically, then permitted thread replies. Record a receipt containing
`head_sha`, `review_url`, posted inline/reply counts, skipped items with reasons,
and errors.

Before reporting success, check that the returned head SHA matches the one
validated before publication and that posted counts plus skipped items account for
every manifest item. A stale head, invalid anchor, malformed receipt, or API
error is a stop: report it without retrying against altered review text.
