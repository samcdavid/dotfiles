# Finding Ledger

Workflow ledgers live in Claude Thoughts at
`~/.claude/thoughts/shared/workflows/`, never in the repository. Discover the
matching ledger there before deciding whether one is available, then use this
reference whenever one is found. It gives review and feedback work one durable,
append-only record of a finding's final disposition. It is not a replacement for
GitHub thread state: a thread may still need a reply or resolution after its
underlying finding has been settled.

## Register shape

Keep one `## Finding Register` section in the ledger. Append one row only when
an item has a final outcome:

```markdown
| Key | Status | Finding | Evidence and disposition | Commit or follow-up | Recorded |
| --- | --- | --- | --- | --- | --- |
| `auth.refresh-expiry` | resolved | Refresh accepts expired token | Regression test + `abc1234` | `abc1234` | 2026-08-24, Feedback Round 2 |
| `canvas.diary-readback` | deferred | Diary readback needs persistence | Outside this slice; MCP-722 explicitly owns it | MCP-722 | 2026-08-24, Feedback Round 2 |
| `review-handoff.local-sensitive-changes` | accepted | Local advisory acknowledgement | User explicitly acknowledged the config/infra/suppression/modified-existing-test anchors; accepted scope: `<category>:<path>:<changed_content_digest>`, review base `<sha>` | user acknowledgement | 2026-08-27, Local Acknowledgement |
| `review-handoff.operational-readiness` | accepted | Operational readiness confirmation | User explicitly confirmed env vars and flags are set appropriately in every staging/production environment and migrations were tested successfully in staging; confirmed scope: `<category>:<path>:<changed_content_digest>`, review base `<sha>` | user confirmation | 2026-08-28, Local Acknowledgement |
```

The only final statuses are:

- `resolved` — a fix was independently verified, the concern was already
  addressed, or evidence-backed investigation established that no change is
  needed.
- `deferred` — the concern is valid but truly out of scope, with a concrete,
  verified follow-up ticket, owner, or clearing condition.
- `accepted` — only for `change-set-risk.md`'s local human acknowledgements. For
  `review-handoff.local-sensitive-changes`, the user explicitly acknowledged
  the advisory changes. For `review-handoff.operational-readiness`, the user
  explicitly confirmed the category-specific external readiness facts; generic
  acknowledgement is insufficient. Never use this status to settle a defect,
  ordinary suggestion, requirement gap, or unverified claim.

Use a stable `Key`: `<affected behavior or subsystem>.<short concern>`. Base it
on the causal behavior and symbol/module, not a line number, reviewer wording,
or severity. Reuse the same key for the same concern in later rounds. A record
must include the source round, evidence, and the exact commit or follow-up that
settled it.

## Re-review behavior

Before review dispatch or feedback triage, read the latest row for each key. A new
candidate that matches a prior `resolved` or `deferred` row is not a fresh
finding and must not consume another repair pass or be re-presented verbatim.
Report it compactly as an existing disposition when useful.

For each handoff key, retain the latest `accepted` row's normalized trigger
tuples. `review-handoff.local-sensitive-changes` covers only advisory tuples;
`review-handoff.operational-readiness` covers only environment-variable,
feature-flag, and migration tuples. Never let the former satisfy the latter.
Advisory tuples may include `modified-existing-test`; operational tuples never
do.
Suppress a local acknowledgement when every current tuple is covered by its
matching key. If any category, path, or changed-content digest is new, ask once
for only that uncovered set and append a new `accepted` row containing the full
current scope after the required acknowledgement or confirmation. Line numbers
are presentation anchors, not scope identity.

The outer `my-review` wrapper owns this append. Record a faithful copy of the
user's response; the full sorted trigger tuples; review mode, base, and current
HEAD when available; and `Recorded: <date>, Local Acknowledgement`. For the
operational-readiness key, the evidence text must state each applicable
environment/flag/migration fact explicitly. Update only the ledger frontmatter's
`updated:` date in addition to appending the row. Never rewrite a prior
acceptance row, and never create a ledger solely for this confirmation.

Reopen the concern only with new, specific evidence: the affected behavior was
changed or regressed after the recorded commit, the prior evidence is disproven,
or the deferred follow-up/clearing condition has materially changed. Record the
new final disposition as another row with the same key and explain the reopen
trigger. Never silently overwrite historical rows.

Do not falsely close an item. A fresh substantive finding awaiting a user scope
decision, a repair attempt, or a missing follow-up remains an active handoff and
is not entered in the register until it can honestly be marked `resolved` or
`deferred`. An unanswered or declined local human acknowledgement is likewise not
`accepted`.
