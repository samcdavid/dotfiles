---
name: log-work
description: Log what was accomplished in the current session to the daily Notion doc. Appends brief actions (fixes, implementations, reviews, investigations) to today's entry. Use at the end of a work session or after completing something notable.
---

# Log Work

Append a brief record of what was accomplished in this session to today's entry in my yearly ToDo doc on Notion. Search Notion for the doc titled with the current year (e.g., "2026 ToDo").

## Step 1 — Review the Session

Look at what happened in this conversation:
- Code changes made (files edited, features implemented, bugs fixed)
- PRs created, reviewed, or updated
- Issues investigated or resolved
- Plans created or validated
- Anything else substantive

Also check git for concrete evidence:
```bash
git log --oneline --since="today" --author="sam"
git diff --stat HEAD~5..HEAD  # recent changes for context
```

## Step 2 — Fetch Today's Entry

Fetch today's entry from the Notion doc. Read what's already there so you don't duplicate anything.

## Step 3 — Append Actions

Add brief action items to today's entry. Each action should be one line:
- Include the Linear issue ID if applicable
- Include a PR link if one was created or updated
- Describe WHAT was done, not HOW — keep it brief

Format:
```
- Fixed failing test suite for ABC-123 (PR: <link>)
- Implemented webhook retry logic for ABC-456
- Reviewed PR #1234 — flagged cross-service contract issue
- Investigated staging error in Figma integration, added error handling
```

Do NOT:
- Duplicate actions already recorded in today's entry
- Include trivial actions (typo fixes, import reordering)
- Write more than one line per action
- Include implementation details — just the outcome

## Step 4 — Confirm

Tell me what was logged.
