---
model: sonnet
name: pr-review-loop
description: "Batch-process GitHub PRs by running my-review then publish-review on each one in sequence, publishing as it goes. Takes an explicit PR list, or auto-discovers PRs in the current repo where the user left feedback that hasn't been re-reviewed."
when_to_use: "Use when the user gives a list of PR numbers to review and publish, or asks to sweep the current repo for PRs where they left a comment/changes-requested that hasn't had a follow-up look, instead of doing them one at a time."
---

# PR Review Loop

Run each PR through `my-review` -> `publish-review`, in sequence, publishing every review as it goes. Takes an explicit PR list, or — with none given — auto-discovers PRs in the current repo that need a follow-up look.

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
   - **Auto-discovery**: none given — run `scripts/discover-review-queue.sh`, scoped to the current repo (via `gh repo view`). It keeps only PRs where my *latest* review is `COMMENTED` or `CHANGES_REQUESTED` — dropping both `APPROVED` PRs and PRs I've never reviewed at all, since this mode is for catching up on feedback I already gave, not first-time reviews.
2. For each PR, in order:
   - Pre-check state; skip merged/closed PRs.
   - Run `my-review` in PR mode.
   - Run `publish-review` immediately after — invoking this skill is the batch's standing approval to publish every PR it processes, the same as `publish-review`'s own single-PR convention.
3. Record one ledger line per PR (verdict, published event, comment/reply counts, URL, or skip/failure reason) and drop that PR's raw findings from context before starting the next one.
4. Apply the three-strike rule **per PR**: a PR that fails twice more after its first failure gets skipped and reported, not retried indefinitely — one bad PR never stalls the batch.
5. After the last PR, report the full progress table.

In explicit mode, always re-review every named PR, even one reviewed before at the same commit — `my-review` already dedupes new findings against its `existing_comments_index` (including its own prior passes), so a re-review does not re-post what's already there. In auto-discovery mode, the keep-list filter runs before the loop starts (Step 1): only PRs where my last review was `COMMENTED` or `CHANGES_REQUESTED` make it in — both already-approved PRs and never-reviewed PRs are excluded, since this mode exists to catch up on feedback already given, not to approve for the first time or re-approve.

## Output

A table of every PR processed: number, verdict, published (event + inline/reply counts), or the skip/failure reason. Call out anything skipped for being merged/closed, and anything that failed after retries.
