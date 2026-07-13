---
model: sonnet
name: daily-wrapup
description: End-of-day companion to daily-summary. Consolidates today's Notion entry — identifies what was accomplished, summarizes Linear ticket activity, and rewrites the Actions/Decisions and Notes sections for readability.
disable-model-invocation: true
---

# Daily Wrapup

End-of-day workflow that closes out today's Daily ToDo page. Read-only on Linear — does not transition ticket states, just summarizes what changed. Read/write on the Notion page — rewrites Actions/Decisions and Notes for clarity and adds a Linear Updates block.

Tomorrow's daily-summary will still own writing the **Summary** section and setting the page **Status** to Complete. This skill stays out of those.
