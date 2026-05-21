# Learned Misses — pattern queue

Patterns the skill should learn to catch (or has caught and confirmed are recurring). Entries accumulate Evidence over time. When `len(evidence) >= 3`, an entry is auto-promoted into the relevant lens reference or `gotchas.md`.

See `SKILL.md` § "Queue lifecycle and auto-promotion" for rules.

## Schema

Each entry is a markdown subsection with:

- **Shape** — the general pattern (the load-bearing field; matching new captures against existing Shapes appends Evidence rather than creating duplicates)
- **Trigger signals** — what in a diff should make the skill stop and check this pattern
- **Evidence** — list of `- {type: caught|missed|noted, ref: <pr#/comment-link/session>, date: YYYY-MM-DD}` entries
- **Proposed promotion** — optional at capture; `target: <file>` + draft `wording:` (required for hard auto-promote — otherwise target is inferred and wording is generated)
- **Status** — `pending` | `ready` | `promoted (YYYY-MM-DD)` | `discarded (YYYY-MM-DD, reason)`

## Pending

<!-- Entries with status: pending or ready live here. Order: most recently updated first. -->

_No pending entries._

## Promoted

<!-- Entries with status: promoted (preserved for audit, never deleted automatically). -->

_No promoted entries._

## Discarded

<!-- Entries with status: discarded (preserved for audit, never deleted automatically). -->

_No discarded entries._
