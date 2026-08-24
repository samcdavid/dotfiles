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
```

The only final statuses are:

- `resolved` — a fix was independently verified, the concern was already
  addressed, or evidence-backed investigation established that no change is
  needed.
- `deferred` — the concern is valid but truly out of scope, with a concrete,
  verified follow-up ticket, owner, or clearing condition.

Use a stable `Key`: `<affected behavior or subsystem>.<short concern>`. Base it
on the causal behavior and symbol/module, not a line number, reviewer wording,
or severity. Reuse the same key for the same concern in later rounds. A record
must include the source round, evidence, and the exact commit or follow-up that
settled it.

## Re-review behavior

Before fan-out or feedback triage, read the latest row for each key. A new
candidate that matches a prior `resolved` or `deferred` row is not a fresh
finding and must not consume another repair pass or be re-presented verbatim.
Report it compactly as an existing disposition when useful.

Reopen the concern only with new, specific evidence: the affected behavior was
changed or regressed after the recorded commit, the prior evidence is disproven,
or the deferred follow-up/clearing condition has materially changed. Record the
new final disposition as another row with the same key and explain the reopen
trigger. Never silently overwrite historical rows.

Do not falsely close an item. A fresh substantive finding awaiting a user scope
decision, a repair attempt, or a missing follow-up remains an active handoff and
is not entered in the register until it can honestly be marked `resolved` or
`deferred`.
