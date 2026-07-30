# Protocol — pr-review-loop

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail.

## Getting Started — Resolve the PR List

Two modes, chosen by whether `$ARGUMENTS` names PRs:

### Explicit mode

`$ARGUMENTS` (or the conversation) names PR references. Accepted forms, any mix:

- Bare numbers: `123 456 789` or `123, 456, 789`
- `#`-prefixed: `#123`
- Cross-repo: `owner/repo#123`
- Full PR URLs: `https://github.com/owner/repo/pull/123`

For any bare number or `#number` with no repo attached, resolve the repo once via `gh repo view --json owner,name` and apply it to every bare reference.

Explicit mode processes every PR named, with **no approval-state filtering** — naming a PR is explicit intent, and it always gets a fresh review regardless of prior review history (see "Always re-review" in `SKILL.md`).

### Auto-discovery mode

`$ARGUMENTS` names no PRs. Discover what's actually worth a second look in the **current repo** instead of asking for a list:

```bash
scripts/discover-review-queue.sh
```

Run this from (or have it resolve) the repo the current session is actually working in — it scopes to that one repo via `gh repo view`, not across every repo the account can see. It prints one NDJSON object per PR still worth reviewing: `{"owner", "repo", "number", "title", "url", "draft"}`. Empty output means nothing left to review — say so and stop (see below).

The script exists so discovery runs the same way every time rather than being re-derived ad hoc each run — that matters here specifically because the naive first draft got the `gh search prs` JSON field wrong (`.repository.fullName` — correct for `gh search commits`, but `gh search prs` uses `.repository.nameWithOwner`), which would have silently produced `owner=null` on every call. It:

- Filters `gh search prs --review-requested=@me` to `--repo <current repo>`, resolved via `gh repo view --json nameWithOwner`. Scoped deliberately, not a gap: this loop tracks the repo the calling session is in, not the account's whole review queue everywhere.
- Excludes only already-approved PRs: a PR is dropped if this user's own *latest* review on it is `APPROVED` — nothing left to review once you've signed off. Never-reviewed (no review yet), `COMMENTED`, and `CHANGES_REQUESTED` are all kept, so this surfaces both first-time review requests and PRs worth a second look after earlier feedback.
- "Latest" matters, not "ever": GitHub can leave/re-add a PR to the review-requested queue after an approval (e.g. new commits under a branch-protection rule that dismisses stale reviews) — the script sorts by `submitted_at` and checks the last state, not whether an approval ever happened anywhere in the history.

Print the discovered, filtered list before starting the loop (`Discovered N PRs to review: ...`) so it's visible what's about to be processed — this is informational, not a gate; per the standing-approval convention below, discovery does not pause for confirmation.

### Build the Working List

Either mode produces `(owner, repo, number)` tuples. Order matters only for the progress table — there is no dependency between PRs, but they are processed **sequentially, not in parallel**: `my-review` fans out several lens-reviewer subagents per PR, and running multiple PRs' reviews concurrently would multiply that fan-out and risk colliding on GitHub's secondary rate limit (80 content-creating requests/minute) when publishing back to back.

If explicit mode finds no PR references and auto-discovery finds zero open review requests, say so and stop — do not guess a range or invent PRs to process.

## Per-PR Loop

For each `(owner, repo, number)` tuple, in order:

### Step 1 — Pre-check

```bash
gh api "repos/${owner}/${repo}/pulls/${number}" --jq '{state, merged, draft, title}'
```

- `state == "closed"` (merged or not): **skip**. Reviewing/publishing to a closed PR provides no value and some review actions may be rejected by the API. Record the skip with reason `closed` or `merged`.
- `draft == true`: proceed normally in either mode — a named PR is explicit intent, and a discovered PR was actually requested for review, so draft status alone is not a reason to skip. Note `draft` in the ledger line so it's visible in the final table.
- If the `gh api` call itself fails (bad PR number, no access, repo typo): treat as this PR's first failure (see Failure Handling below), not a reason to abort the batch.

### Step 2 — Review

Invoke `my-review` (via the `Skill` tool) in PR mode, targeting this PR. Let it run its full flow — mode routing, lens fan-out, adversarial-debate on findings, verdict. Do not shortcut or summarize its inputs; it needs the real PR context to build its `existing_comments_index` and dedupe correctly.

### Step 3 — Publish

Immediately invoke `publish-review` (via the `Skill` tool) for the same PR. Per this skill's own convention ("Invoking this skill is the approval — publish immediately without asking for confirmation"), and per `pr-review-loop`'s own contract that invoking the loop is the batch's standing approval, do not pause for a separate per-PR confirmation here.

**Why no extra dedup step is needed.** The loop always re-reviews every PR, even ones reviewed before at the same commit. This is safe against duplicate noise because `my-review` already builds an `existing_comments_index` (file/line/substance/thread-root) before its lens reviewers run, dedupes new findings against it during merge, and explicitly treats a PR with the reviewer's own prior pass as a re-review ("re-read the full diff and all comments... where authors may explain what changed"). `publish-review` separately validates every reply target against current comment state. Between the two, a repeat run over the same PR list should surface only genuinely new findings, not restate old ones — verify this holds by skimming `my-review`'s findings for repeats of clearly-already-addressed items before publishing; if dedup ever visibly fails, that's a `my-review` gotcha to capture, not something to patch inside this loop.

### Step 4 — Record and Checkpoint

Append one ledger line:

```
- PR #<number> (<owner>/<repo>)<, draft if applicable> — <verdict> — published: <event> (<N> inline, <M> replies) — <url>
```

or, for a skip/failure:

```
- PR #<number> (<owner>/<repo>) — SKIPPED: <reason>
- PR #<number> (<owner>/<repo>) — FAILED after <k> attempts: <error/root cause>
```

Per `context-checkpoint.md`: once this line is recorded, the full findings text, diff, and any subagent transcripts from Steps 2-3 for this PR are no longer needed. Do not re-quote them when starting the next PR — carry forward only the ledger.

## Failure Handling — Three Strikes, Scoped Per PR

Apply `loop-detection.md`'s rule to each PR independently, not to the batch as a whole:

1. **First failure** (Step 1, 2, or 3): diagnose — check `gh auth status`, confirm the PR number/repo resolved correctly, check for an obvious transient error (rate limit, network) — and retry once with the fix applied.
2. **Second same-root failure**: one more targeted retry.
3. **Third same-root failure**: stop attempting this PR. Record it as `FAILED` with the repeated error and a best root-cause theory. Move on to the next PR in the list — a stuck PR never blocks the rest of the batch.

## Final Report

After the last PR (or after the list is exhausted, however many were skipped/failed), print the full ledger as a table, plus counts: processed / published / skipped / failed. Call out every skip and failure by number so nothing silently drops off the list.

## References

- `scripts/discover-review-queue.sh` — auto-discovery mode's backing script; runs independently of this skill for spot-checking (`scripts/discover-review-queue.sh`, no arguments).
