---
model: sonnet
name: pr-review-loop
description: "Batch-process GitHub PRs by running my-review then publish-review on each one in sequence, publishing as it goes. Takes an explicit PR list, or auto-discovers open review requests in the current repo, skipping ones already approved."
when_to_use: "Use when the user gives a list of PR numbers to review and publish, or asks to review whatever PRs are currently requested of them in the current repo, instead of doing them one at a time."
---

# PR Review Loop

Run each PR through `my-review` -> `publish-review`, in sequence, publishing every review as it goes. Takes an explicit PR list, or — with none given — auto-discovers open review requests in the current repo, excluding ones already approved.

## Load Rules

Read first:

- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/pr-cost-control.md`

Use `~/.agents/rules/` under Codex.

For PR-list parsing (explicit and auto-discovery), per-PR skip conditions, failure handling, and the dedup rationale, read `references/protocol.md`.

## Flow

1. Resolve the working list of `(owner, repo, number)` tuples from `$ARGUMENTS`:
   - **Explicit**: PR numbers/URLs given — use them as-is, no approval filtering.
   - **Auto-discovery**: none given — run `scripts/discover-review-queue.sh`, scoped to the current repo (via `gh repo view`). It drops a PR only if my *latest* review on it is `APPROVED`; never-reviewed, `COMMENTED`, and `CHANGES_REQUESTED` are all kept.
2. For each PR, in order:
   - Pre-check with `scripts/pre-check-pr.sh`; skip merged/closed PRs. This runs for every PR in both modes — it catches a PR merging *between* discovery and review in a multi-PR batch, and it's the only state check explicit-mode PRs get at all.
   - Run `my-review` in PR mode.
   - Run `publish-review` immediately after — invoking this skill is the batch's standing approval to publish every PR it processes, the same as `publish-review`'s own single-PR convention.
3. Record one ledger line per PR (verdict, published event, comment/reply counts, URL, or skip/failure reason) and drop that PR's raw findings from context before starting the next one.
4. Apply the three-strike rule **per PR**: a PR that fails twice more after its first failure gets skipped and reported, not retried indefinitely — one bad PR never stalls the batch.
5. **Auto-discovery only:** re-run `scripts/discover-review-queue.sh` and repeat from step 2 over any PR not already processed this run, until a call returns nothing new (capped at 25 outer-loop iterations as a safety net). The stop condition is "nothing new," not "the script returned empty" — a PR that only ever earns a `COMMENT` verdict stays in the script's output forever (it's never `APPROVED`), so looping on raw-empty output would never terminate.
6. After the last iteration, report the full progress table.

In explicit mode, always re-review every named PR, even one reviewed before at the same commit — `my-review` already dedupes new findings against its `existing_comments_index` (including its own prior passes), so a re-review does not re-post what's already there. In auto-discovery mode, the approved-exclusion runs before the loop starts (Step 1): only already-approved PRs are dropped, since re-approving something already signed off on adds no value — everything else in the queue, including PRs never reviewed at all, gets processed.

## Output

A table of every PR processed: number, verdict, published (event + inline/reply counts), or the skip/failure reason. Call out anything skipped for being merged/closed, and anything that failed after retries.
