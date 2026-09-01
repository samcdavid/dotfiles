# Isolated Haiku publisher

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

Run one isolated delegate from the repository root. Give it the manifest path,
not the surrounding conversation:

```bash
claude --model haiku --no-chrome --strict-mcp-config --allowed-tools Bash Edit Read --dangerously-skip-permissions -p "Publish only the prepared review in <manifest-path>. Read that file. Fetch the current PR head, aggregate diff, and filtered review-thread data. Reject the entire publication if EXPECTED_HEAD_SHA is stale or an inline comment is not anchored in the aggregate diff. Deduplicate exact existing comments and normalize replies to their top-level comment. Do not rewrite, add, move, or turn an invalid new inline finding into a PR-level comment. Submit the review atomically, then permitted thread replies. Return only JSON: {head_sha, review_url, posted_inline_count, posted_reply_count, skipped:[{item, reason}], errors:[]}."
```

If the Haiku command cannot run, `codex --model gpt-5.6-luna exec "<same
publication task>"` is an acceptable fallback. It receives the same manifest
path and no additional authority.

Before reporting success, check that the returned head SHA matches the one
validated by the delegate and that posted counts plus skipped items account for
every manifest item. A stale head, invalid anchor, malformed receipt, or API
error is a stop: report it without retrying against altered review text.
