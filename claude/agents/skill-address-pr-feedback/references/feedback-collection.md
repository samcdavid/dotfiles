# Feedback collection — skill-address-pr-feedback

Load only in PR mode. Read `pr-cost-control.md` and `pr-mode-readonly.md`
before fetching. The PR head and aggregate diff are truth; do not substitute
working-tree files for PR content.

Fetch a compact PR summary and diff, then the filtered GraphQL review-thread
shape from `pr-cost-control.md`. Fetch filtered review bodies or issue comments
only when a pending item is not represented by a review thread. Do not ingest
raw GitHub payloads.

For each pending item retain only: reviewer, comment type, path/line when
present, original text, top-level numeric comment ID, GraphQL thread ID,
resolution/outdated state, and enough nearby diff/code context to investigate.
Treat a reply with a commit SHA or clear completion acknowledgement as already
addressed unless new changed-code evidence reopens it.

If the PR description links a ticket, fetch its acceptance criteria. Combine
them with a discovered workflow ledger's requirements into a concise map only
when the feedback or proposed fix can affect a requirement. Do not build a
requirements map for a comment-only or formatting-only round.
