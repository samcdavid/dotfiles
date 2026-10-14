# Daily ToDo page template

Same properties and section order every run. Never reorder, drop, or add sections.

## Properties

- `Day` (title) = output of `date +'%A, %B %-d, %Y'` — never compute the weekday yourself
- `date:Date:start` = output of `date +%Y-%m-%d`
- `Status` = "Active"
- `Day Type` = "Workday" (or "PTO"/"Holiday" if today is a day off)

## Content

```
## Daily Update
## Checklist
## Actions and decisions
## Notes
## Summary
## Linear Updates        ← added at end of day only
```

## Daily Update format

One sentence per bullet: Linear ID (no title), current status, PR link if any.

```
Y:
- ABC-123: moved to code review (PR: <link>)

On-call:
- Sat 5/30: paged for API 5xx spike on X, mitigated by Y (<ticket>)

T:
- ABC-123: verify in staging

OOO:
- OOO Mon 3/30 – Wed 4/1, back Thu 4/2

PL:
- <only if it genuinely needs the whole team>
```

Omit `On-call:`, `OOO:`, and `PL:` when empty.

## Linear Updates entry shapes

Order by significance (Done > transition > in-progress > comments), one line each:

- `MCP-32 — In Review → Done; merged 18:06 (<PR>)`
- `MCP-44 — Backlog → In Progress; PR opened (<PR>)`
- `MCP-40 — still In Progress; split into MCP-50 / MCP-51`
- `MCP-12 — left review on PR #1234 (changes requested)`
