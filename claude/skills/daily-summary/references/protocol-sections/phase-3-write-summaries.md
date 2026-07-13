## Phase 3 — Write Summaries

Write a **## Summary** for **each** reviewed page — the previous workday and every on-call day — using `notion-update-page` with `update_content`. After writing each summary, set that page's Status property to "Complete".

**Previous workday.** Write it in a way that would be useful for a future performance review:
- Emphasize impact, decisions made, and problems solved.
- Note meaningful collaboration or unblocking others.
- Keep it concise but substantive — a few sentences, not a task list.

**On-call days.** Write an incident-flavored summary that will be useful for a post-mortem and a performance review:
- Lead with what triggered the page and the impact (what was broken, who/what was affected).
- State the resolution and how it was reached — root cause if known, mitigation applied.
- Note follow-ups created (tickets to file, fixes deferred to business hours).
- Keep it concise; the page's Actions and decisions already hold the timeline detail.
