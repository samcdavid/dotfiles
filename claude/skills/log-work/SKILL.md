---
model: haiku
name: log-work
description: Log what was accomplished in the current session to the daily Notion doc. Appends brief actions (fixes, implementations, reviews, investigations) to today's entry. Use at the end of a work session or after completing something notable.
---

# Log Work

Append a brief record of what was accomplished in this session to today's entry in the Daily ToDo Notion database.

`$ARGUMENTS` should contain a **Notion database URL** for the Daily ToDo database. If missing, ask the user before proceeding. Fetch the database URL to discover its data source ID (look for the `<data-source url="collection://...">` tag). Use this data source ID for all subsequent queries and page creation.

## Step 1 — Review the Session

Skim git and the conversation for substantive outcomes: code shipped, PRs reviewed, investigations resolved, decisions made.

```bash
git log --oneline --since="today" --author="sam"
```

## Step 2 — Fetch Today's Entry

Query the Daily ToDo database (using the data source ID resolved above) for today's page:
```
SELECT * FROM "<data_source_id>" WHERE "date:Date:start" = '<today YYYY-MM-DD>'
```
If found, fetch the page content to see what's already logged. If not found, create today's page first using `notion-create-pages` with the resolved data source ID (properties: `Day` = "<DayOfWeek>, <Month> <Day>, <Year>", `date:Date:start` = "<YYYY-MM-DD>", `Status` = "Active", `Day Type` = "Workday") with empty sections (## Checklist, ## Actions and decisions, ## Notes, ## Summary).

## Step 3 — Append Actions

The reader is future-Sam scanning a week of entries. Each bullet must be readable in 2 seconds.

### Hard caps

- **One sentence per bullet.** If you need two, you have two entries — or you're explaining HOW instead of WHAT.
- **≤ 30 words before refs.** Count them.
- Refs go in parens at the end: `(PR #25649)`, `(commit 71d3c47f305 on PR #25649)`. Never embed mid-sentence.

### Do not include

- File paths, line numbers, function names, regex, config keys, framework internals — the PR/commit link carries that detail.
- Test counts, CI status, "all green", file/test counts.
- Enumerations of ruled-out hypotheses — collapse to one phrase: *"ruled out X and Y in favor of Z"* or omit entirely.
- Restated PR titles or commit messages — assume the link suffices.
- The mechanics of meta-skills (`/you-sure`, `/this-important`, adversarial-debate, `/prove-it`) — only their net effect.

### Shape

```
- <ticket>: <outcome in one sentence> (refs)
- Reviewed PR <#> (<ticket>, <one-phrase summary>) — <verdict>, <findings or "no blockers">
```

### Good

```
- ABC-123: added structured rejection logging to the auth middleware so failures distinguish header-stripping from bad client tokens (commit abc1234 on PR #1234)
- ABC-123: fixed staging post-OAuth failures — slash-redirect dropped auth and the server ignored the proxy's forwarded-proto header (commit def5678 on PR #1234)
- ABC-123: rejected the one-line metadata-side bandaid in favor of fixing the underlying redirect, removing the bug class app-wide
- Reviewed PR #2345 (XYZ-456, schema enrichment + scroll fix) — COMMENT, no blockers; flagged a pre-existing a11y gap as a follow-up
- Reviewed PR #2346 (XYZ-457, supervisor silent-fallback) — concurred APPROVE post-merge, for the record
```

### Bad — do not write entries like this

```
- ABC-123: added missing logger.info("auth_rejected", ...) calls on the middleware's token_missing and token_invalid paths (commit abc1234 on PR #1234) — these were the two most common rejection paths but logged nothing, so the prior investigation had to fall back on direct curl probes. Refactored _extract_token to return (token, sub_reason) with sub_reason ∈ {"no_auth_header", "wrong_scheme", ...}; 401 body stays token_missing so adversarial clients aren't telegraphed internal state.
```

That's one entry, four sentences, ~120 words, with quoted code. Split or cut.

### PR Review Sessions

When the session was a PR review, log:
- PR (number + ticket + one-phrase summary)
- Verdict (APPROVE / COMMENT / REQUEST CHANGES) and the findings the author will actually see in the published review
- "Almost-findings" — issues suspected but dropped after verification — as one bullet: *"thought I had found X, but upon further inspection it was not an issue."*

Forward-watch / follow-up observations from a review are fine to log IF they survived into the published review. If they didn't, they don't belong here either.

Do NOT log how findings were filtered (which gate dropped what). Internal scaffolding, not log content.

## Step 4 — Confirm

Tell the user what was logged in one line.
