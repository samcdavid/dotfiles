---
model: haiku
name: start-day
runner: skill-start-day
description: Build a daily work brief from yesterday/off-hours activity plus today's Linear, Calendar, Gmail, and Notion context; update Notion with a reviewable daily update and checklist.
disable-model-invocation: false
---

# Start Day

Create the daily work summary and planning brief through the `skill-start-day` runner. This wrapper supplies the request context, preserves the user-facing approval boundary, and renders the runner's completed artifact.

## Dispatch

Pass the Notion database URL from `$ARGUMENTS`, current date/context, and available connected-tool capabilities to `skill-start-day`.

If the database URL is missing, ask the user for it. Do not infer one from unrelated context.

The runner may update the requested Daily ToDo Notion entry, but it must return any request to post, send, publish, push, or otherwise act outside that entry to this wrapper for explicit user authorization.

## Present

Return the runner's updated Notion entry, daily-update text, top priorities, calendar conflicts, and follow-ups. Do not post the update to Slack.
