---
model: sonnet
effort: medium
name: end-day
runner: skill-end-day
description: Consolidate today's Notion entry, summarize Linear/work activity, and rewrite actions, decisions, and notes into a clean end-of-day record.
disable-model-invocation: false
---

# End Day

Produce a concise end-of-day record from today's work artifacts through the `skill-end-day` runner. This wrapper supplies context, preserves the user-facing approval boundary, and renders the completed artifact.

## Dispatch

Pass the Notion database URL from `$ARGUMENTS`, current date/context, and available connected-tool capabilities to `skill-end-day`.

If the database URL is missing, ask the user for it. Do not infer one from unrelated context.

The runner may update the requested Daily ToDo Notion entry, but it must return any request to post, send, publish, push, or otherwise act outside that entry to this wrapper for explicit user authorization.

## Present

Return what changed in Notion, a short accomplishment summary, open actions, blockers, and tomorrow carry-over. Do not post the record to Slack.
