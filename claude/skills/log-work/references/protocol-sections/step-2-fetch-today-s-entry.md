## Step 2 — Fetch Today's Entry

Query the Daily ToDo database (using the data source ID resolved above) for today's page:
```
SELECT * FROM "<data_source_id>" WHERE "date:Date:start" = '<today YYYY-MM-DD>'
```
If found, fetch the page content to see what's already logged. If not found, create today's page first using `notion-create-pages` with the resolved data source ID (properties: `Day` = "<DayOfWeek>, <Month> <Day>, <Year>", `date:Date:start` = "<YYYY-MM-DD>", `Status` = "Active", `Day Type` = "Workday") with empty sections (## Checklist, ## Actions and decisions, ## Notes, ## Summary).
