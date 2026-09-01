---
model: sonnet
name: publish-review
description: Publish prepared PR review to GitHub inline comments, thread replies, review body via gh api.
---

# Publish Review

Publish an already prepared review through one isolated Claude Haiku session.
Invoking this skill is the user's explicit approval to publish; otherwise do
not invoke it. The wrapper must not reinterpret, rewrite, or invent findings.

Create the compact plain-text review manifest described in
`references/haiku-publisher.md`, then invoke its exact Haiku command. Supply
only the PR identifier and the prepared review/comment text in that manifest;
Haiku fetches the current, filtered GitHub state itself. It may publish only the
manifest's review body, inline comments, and replies. Return its receipt and
call out any item it rejected instead of silently changing it.
