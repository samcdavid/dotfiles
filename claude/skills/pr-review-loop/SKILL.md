---
model: sonnet
name: pr-review-loop
description: "Review and publish up to three GitHub PRs per run from an explicit list or the current repo's open review requests, then stop for a fresh context."
when_to_use: "Use when the user gives a list of PR numbers to review and publish, or asks to review whatever PRs are currently requested of them in the current repo, instead of doing them one at a time."
---

# PR Review Loop

Review and publish up to three PRs sequentially, then stop for a fresh context. Take an explicit PR list or auto-discover open review requests in the current repo.

## Load Rules

Read first:

- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/pr-cost-control.md`

Use `~/.agents/rules/` under Codex.

For PR-list parsing (explicit and auto-discovery), per-PR skip conditions, failure handling, the claim ledger's concurrency guarantees, and the dedup rationale, read `references/protocol.md`.

## Flow

0. Generate one session id for the whole run and reuse it on every claim/release call: `printf 'pr-loop-%s-%s\n' "$(date -u +%H%M%S)" "$RANDOM"`. Record it in the run header.
1. Resolve the working list of `(owner, repo, number)` tuples from `$ARGUMENTS`:
   - **Explicit**: PR numbers/URLs given — use them as-is, no approval filtering.
   - **Auto-discovery**: none given — run `scripts/discover-review-queue.sh`, scoped to the current repo (via `gh repo view`). It drops a PR only if my *latest* review on it is `APPROVED`.
2. **Shuffle the working list** through `scripts/shuffle-queue.sh`, in both modes. Sessions walking the same queue in the same order contend on every PR; random order spreads them out.
3. For each PR, in shuffled order, until three PRs have entered `my-review`:
   - **Claim it first**, before any other work: `scripts/claim-pr.sh <owner> <repo> <number> --session <id>`. On `"claimed": false` another session holds it — record `SKIPPED: claimed-elsewhere`, treat it as processed, move on. Never review a PR this session does not hold.
   - Pre-check with `scripts/pre-check-pr.sh`; skip merged/closed PRs. It also returns `head_sha`.
   - **Auto-discovery only:** `scripts/check-reviewed.sh <owner> <repo> <number> --sha <head_sha>`. On `"reviewed": true` this exact commit was already reviewed — release the claim, record `SKIPPED: already-reviewed`, move on.
   - Immediately before `my-review`, increment the review count. Then run `my-review` in PR mode and `publish-review`; a PR counts once `my-review` starts, while pre-review skips do not.
   - **Mark it reviewed, then release**, in that order: `scripts/mark-reviewed.sh ... --sha <head_sha> --verdict <verdict> --session <id>`, then `scripts/release-pr.sh ... --session <id>`. Release every PR claimed, on every exit path — published, skipped, or failed.
4. Record one ledger line per PR (verdict, published event, comment/reply counts, URL, or skip/failure reason) and drop that PR's raw findings from context before starting the next one.
5. Apply the three-strike rule **per PR**: a PR that fails twice more after its first failure gets skipped and reported, not retried indefinitely — one bad PR never stalls the batch. Release its claim before moving on.
6. **Auto-discovery only:** re-run `scripts/discover-review-queue.sh` and repeat from step 2 (re-shuffling) over any PR not already processed this run, until a call returns nothing new (capped at 25 iterations) **or the three-review cap is reached**. The stop condition is "nothing new," not "empty output" — a PR that only ever earns `COMMENT` stays in the script's output forever.
7. After the last iteration or third review, report the full progress table and any PRs left unprocessed because of the cap. Stop; do not begin a fourth review in this context.

## Output

A table of every PR processed: number, verdict, published (event + inline/reply counts), or the skip/failure reason. Call out anything skipped for being merged/closed, `claimed-elsewhere`, or `already-reviewed`, anything that failed after retries, and any PRs left for the next run after the three-review cap. State the run's session id and confirm every claim taken was released.
