---
model: sonnet
name: publish-review
description: Publish prepared PR review to GitHub inline comments, thread replies, review body via gh api.
---

# Publish Review

Publish an already prepared review directly. Invoking this skill is the user's
explicit approval to publish; otherwise do not invoke it. The wrapper must not
reinterpret, rewrite, or invent findings.

Create the compact plain-text review manifest described in
`references/publisher-protocol.md`, then follow its validation and publication
procedure directly. Supply only the PR identifier and the prepared
review/comment text in that manifest. Publish only the manifest's review body,
inline comments, and replies. Return the receipt and call out any item rejected
instead of silently changing it.
