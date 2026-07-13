## Step 2 — Find or Create the Day's Page

Fetch the Daily ToDo database in **view mode** (sorted descending by Date, `page_size: 5`, pick the entry whose `date:Date:start` matches the incident date — per the daily-summary `Notion SQL date-filter` gotcha; do not use SQL mode).

- **If no page exists for that date**, create it with `notion-create-pages` using the resolved data source ID:
  - Properties: `Day` = "<DayOfWeek>, <Month> <Day>, <Year>", `date:Date:start` = "<YYYY-MM-DD>", `Status` = "Active", `Day Type` = "On Call".
  - Content: empty `## Checklist`, `## Actions and decisions`, `## Notes`, and `## Summary` sections.
- **If a page already exists** (e.g., an incident landed on a normal workday), append to it — **do not** overwrite its `Day Type` or existing content. The incident timeline is added alongside whatever is already there.
