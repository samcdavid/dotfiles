# Gotchas — pr-review-loop

## "Clean up the review ledger" has two directories with opposite risk profiles

**Trigger:** User asks to "clean up," "clear," or "reset" the review ledger after a run.

**Wrong behavior:** Treating both ledger directories the same way — either refusing to touch anything out of excess caution, or deleting both without checking what's actually in them.

**Correct behavior:** The two directories are not interchangeable:

- `~/.claude/thoughts/shared/pr-review-done/` (reviewed-commit markers) — **safe, low-stakes, user-owned housekeeping.** Deleting entries here only forces those PRs to be re-reviewed on the next auto-discovery run; it never touches or un-does a published GitHub review. If the user says "wipe the done markers," just do it — it's reversible in effect (worst case is redundant future review work) and is a legitimate way to force a fresh pass over PRs already handled.
- `~/.claude/thoughts/shared/pr-review-claims/` (in-flight claim locks) — **check freshness before touching.** A claim file younger than the TTL (default 90 min) likely belongs to another session actively mid-review right now. Deleting it steals the claim out from under live work and risks a duplicate/colliding review. Only remove entries here that are actually stale (older than TTL) or confirmed to belong to a dead session — and say so explicitly when reporting what was removed.

**Why it matters:** Conflating the two leads to either unnecessary hedging (asking the user to clarify when a fresh "done" marker sweep is an obviously safe, reversible-in-effect action) or, worse, blindly deleting a live claim file and causing exactly the duplicate-review problem the claim ledger exists to prevent. Inspect `claimed_at`/age before deciding what's "stale," and don't lump both directories into one clarifying question when only one of them carries real risk.
