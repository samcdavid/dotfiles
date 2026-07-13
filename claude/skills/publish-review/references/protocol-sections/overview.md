---
model: sonnet
name: publish-review
description: Publish a PR review from the current session to GitHub. Formats inline comments, thread replies, and the review body, then posts via `gh api`. Handles line number mapping, reply targeting, and markdown formatting. Manual invocation only.
disable-model-invocation: true
---

# Publish PR Review to GitHub

Publishes a PR review that has been written in the current conversation to GitHub. Supports inline file comments, thread replies to existing comments, and a top-level review body.
