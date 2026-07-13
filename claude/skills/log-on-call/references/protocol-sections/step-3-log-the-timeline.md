## Step 3 — Log the Timeline

Write the incident into the page's **## Actions and decisions** section via `notion-update-page` with `update_content`, appending (not replacing) if the section already has content. If logging a second incident on the same day, start a new block — never merge two incidents into one timeline.

Shape — one timestamped line per step, oldest first:

```
- 23:14 paged: API 5xx spike on checkout (PagerDuty <link>)
- 23:20 confirmed scope: only the EU region, ruled out a deploy (last deploy 6h prior)
- 23:35 root cause: connection pool exhausted after upstream latency spike
- 23:38 mitigated: raised pool ceiling and recycled the affected pods
- 23:45 resolved: 5xx rate back to baseline, confirmed on dashboard <link>
- follow-up: file ticket to add pool-saturation alert + autoscale (deferred to business hours)
```

Rules:
- **Timestamps lead each line** where known; drop the timestamp only when genuinely unknown.
- **Refs in parens** — PagerDuty/incident links, dashboards, PR/commit, Linear ticket. Never embed mid-sentence.
- **One step per line.** Investigation, mitigation, and resolution are separate lines.
- **End with the resolution line and any follow-ups.** Follow-ups deferred to business hours each get their own `follow-up:` line so they're easy to lift into a ticket later.
- Keep each line scannable — what happened, not a paragraph on how.

Leave `## Notes` and `## Summary` empty. Tomorrow's `daily-summary` reviews this page, writes the post-mortem-flavored `## Summary`, and flips `Status` to Complete.
