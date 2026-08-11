# Protocol — pr-review-loop

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail.

## Step 0 — Establish the Session Id

Generate one session id at the start of the run and reuse it for every `claim-pr.sh`, `release-pr.sh`, and `mark-reviewed.sh` call:

```bash
printf 'pr-loop-%s-%s\n' "$(date -u +%H%M%S)" "$RANDOM"
```

Record it in the run's ledger header. Shell state does not persist between tool calls, so this id has to be carried in context and passed explicitly as `--session <id>` on each call — or exported as `PR_REVIEW_SESSION` in each command.

The id is what makes claims attributable: it lets this session re-claim its own PR after a transient failure instead of blocking itself, and it stops a release call from tearing down a claim another session is actively working. A run that skips this step still functions (the scripts fall back to `unknown-$$`, a per-process value), but loses both properties — do not skip it.

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

### Repeat Until Nothing New (auto-discovery mode only)

Calling `discover-review-queue.sh` once only gives a snapshot. Re-run it after each batch and keep going — but **the stop condition is not "the script's output is empty."**

**Why raw-empty is the wrong stop condition.** `my-review`'s approval bar is strict; `COMMENT` is a common, legitimate verdict, not a failure. A PR reviewed with `COMMENT` is not approved, so it correctly stays in `discover-review-queue.sh`'s output on the next call (the script only excludes `APPROVED` PRs). Looping until the script's raw output is literally empty would spin forever on any PR that never reaches full approval.

**The actual stop condition.** Track every `(owner, repo, number)` already processed this run — reviewed, skipped, failed, or skipped as `claimed-elsewhere`, regardless of verdict. Each iteration:

1. Run `scripts/discover-review-queue.sh`.
2. Drop any tuple already in the processed set.
3. If nothing remains, stop — there is nothing left this run hasn't already handled.
4. Otherwise, pipe the remaining tuples through `scripts/shuffle-queue.sh` and run the Per-PR Loop over them, adding each to the processed set as it finishes (Step 7), then go back to step 1.

Re-shuffle every iteration rather than shuffling once and reusing the order: each iteration is a fresh chance for concurrent sessions to fall into lockstep, and a PR another session was mid-review on during iteration 1 is exactly the kind of tuple that reappears in iteration 2.

`claimed-elsewhere` belongs in the processed set for the same reason it counts as processed in the ledger: another session owns that PR. Leaving it out would make the loop re-discover it, re-attempt the claim, and — once the other session finishes and releases — review a PR that was just reviewed.

This still picks up PRs newly requested mid-run and still drops PRs this run itself just approved, without ever reprocessing something already handled. As a safety net against anything unexpected keeping this from converging (e.g. review requests arriving faster than they can be processed), cap outer-loop iterations at 25; if the cap is hit, stop and report what's left rather than spinning indefinitely.

Explicit mode does not use this loop — it processes its fixed list once, in order, with no re-discovery.

### Build the Working List — Then Shuffle It

Either mode produces `(owner, repo, number)` tuples. There is no dependency between PRs, so processing order is free — and it should be **randomized**, not the order discovery or the user happened to supply:

```bash
scripts/discover-review-queue.sh | scripts/shuffle-queue.sh    # auto-discovery
printf '%s\n' 123 456 789 | scripts/shuffle-queue.sh           # explicit
```

Shuffle in **both** modes, and re-shuffle each outer-loop iteration in auto-discovery mode.

**Why shuffle.** Several review sessions are expected to run at once against the same queue. Sessions that walk an identical ordering march in lockstep: every one starts on the same PR, all but one lose the claim race, and they all move to the next PR together and contend again. Random order means they start in different places and mostly work disjoint PRs, so the claim ledger is exercised rarely instead of on every item.

Shuffling is a contention *reduction*, not a correctness mechanism — two random orders can still overlap. Correctness comes from the claim ledger below, which is mandatory regardless of ordering.

Within a single session, PRs are still processed **sequentially, not in parallel**: `my-review` fans out several lens-reviewer subagents per PR, and running multiple PRs' reviews concurrently would multiply that fan-out and risk colliding on GitHub's secondary rate limit (80 content-creating requests/minute) when publishing back to back.

That rate limit is per-user, not per-session, so concurrent sessions share it. Two or three parallel sessions are fine; a dozen will start tripping secondary rate limits on publish no matter how well the claims behave. If publish steps begin failing with rate-limit errors across sessions, the fix is fewer sessions, not more retries.

If explicit mode finds no PR references and auto-discovery's first call finds zero open review requests, say so and stop — do not guess a range or invent PRs to process.

## The Claim Ledger — Don't Duplicate Another Session's Work

Every PR must be claimed before any work happens on it, and the claim released when that work ends. The ledger lives at:

```
~/.claude/thoughts/shared/pr-review-claims/<owner>__<repo>__<number>.json
```

A claim file's presence means "a session is reviewing this PR right now." Its absence means the PR is free.

**One file per PR, not one shared ledger file.** A single shared file would require read-modify-write to add or remove an entry, which has no atomic form without `flock` — and macOS does not ship `flock`. A per-PR file gets real mutual exclusion instead: `claim-pr.sh` writes the payload to a temp file and then hard-links it into place, and `ln` fails if the target already exists. Verified with 20 concurrent claimers on one PR: exactly one winner, nineteen clean losers.

The write-then-link ordering matters and is not incidental. A simpler `O_EXCL`/noclobber redirect is exclusive on *creation* but leaves the file empty for a moment while the payload is still being written — long enough for another session to open it, fail to parse it, conclude the claim is ancient, and steal a PR that is actively being reviewed. That was observed in a 3-session contention test before the fix. Linking a fully-written file closes the window: the name only appears once the content behind it is complete.

### Claiming

```bash
scripts/claim-pr.sh <owner> <repo> <number> --session <id>
```

Always exits 0 — branch on the `claimed` field, never on exit status:

- `{"claimed": true, ...}` — this session holds the PR. Proceed.
- `{"claimed": true, "reclaimed": true}` — this session already held it (e.g. a retry after a transient failure). Proceed; this is not a warning.
- `{"claimed": true, "stolen_from": "<id>"}` — the previous holder's claim was past its TTL and treated as abandoned. Proceed, and note the steal in the ledger line so an over-eager TTL is visible.
- `{"claimed": false, "holder": "<id>", "age_min": N}` — another live session owns it. **Do not review it.** Record `SKIPPED: claimed-elsewhere (holder <id>)` and move on.

A `claimed-elsewhere` skip counts as **processed for this run** and goes into the processed set. Another session is handling that PR; coming back to it later is the exact duplicate work this ledger exists to prevent.

### Releasing

```bash
scripts/release-pr.sh <owner> <repo> <number> --session <id>
```

Release on **every** exit path for a PR this session claimed — after publishing, after a merged/closed skip, and after a terminal three-strike failure. An unreleased claim blocks that PR from every other session until the TTL expires.

Do not release a PR that came back `claimed-elsewhere`; it isn't this session's to release, and the script's ownership check will refuse it anyway (`"reason": "held-by-other"`).

### Stale Claims

A session that crashes mid-review leaves its claim file behind. Without expiry that PR would be unreviewable forever, so a claim older than `PR_REVIEW_CLAIM_TTL_MIN` minutes (default 90) is treated as abandoned and can be stolen.

Age comes from the claim's recorded timestamp, falling back to the file's mtime when the JSON cannot be parsed. The fallback is the point: an unreadable claim file ages out on the same TTL as any other rather than reading as epoch 0 and being instantly stealable, which would turn any momentary read failure into a stolen live claim.

90 minutes is deliberately generous: a large PR with full lens fan-out can legitimately take a long time, and stealing a claim from a session that is merely slow causes the duplicate review the ledger is meant to prevent. If a genuinely stuck claim needs clearing sooner, delete the file or run `release-pr.sh ... --force`.

One residual race is worth knowing: the steal path is unlink-then-create, which is not atomic the way the initial exclusive create is. Two sessions can both decide to steal the same stale claim; each re-reads the file afterward and only the session whose id actually landed proceeds. The loser yields. Worst case if that check were ever bypassed is a duplicated review, which `my-review`'s dedup already blunts — but it is not a licence to skip the claim step.

## The Reviewed Ledger — Don't Redo a Commit Already Reviewed

Claims are held only for the duration of a review, which prevents two sessions reviewing a PR *simultaneously* but not *consecutively*: session A reviews PR #5 and releases it, then session B reaches #5 later in the same wave, finds it free, and reviews it again. A second ledger closes that gap:

```
~/.claude/thoughts/shared/pr-review-done/<owner>__<repo>__<number>.json
```

Each marker records the head SHA that was reviewed, the verdict, the session, and when. The two ledgers answer different questions — the claim ledger asks "is someone reviewing this right now," the reviewed ledger asks "has this exact commit already been reviewed" — and neither substitutes for the other.

**Keyed by head SHA, deliberately.** The marker self-invalidates: a push produces a new SHA, so the PR becomes reviewable again with no expiry rule and no cleanup, while an untouched PR stays skipped. A time-keyed marker would have to choose between re-reviewing unchanged PRs and suppressing review of freshly pushed ones. `pre-check-pr.sh` returns `head_sha` for exactly this purpose, so the SHA checked is the one fetched moments earlier, not a stale value from discovery.

### Checking

```bash
scripts/check-reviewed.sh <owner> <repo> <number> --sha <head_sha>
```

- `{"reviewed": true, ...}` — this commit was already reviewed (by any session, this run or a previous one). Release the claim, record `SKIPPED: already-reviewed (<verdict> at <sha>)`, and treat it as processed.
- `{"reviewed": false, "reason": "no-marker"}` — never reviewed. Proceed.
- `{"reviewed": false, "reason": "sha-changed"}` — reviewed at an older commit; the author has pushed since. Proceed, and note the prior verdict in the ledger line.

The check **fails open**: an unparseable marker reports `reviewed: false` and the PR gets reviewed. A redundant review is a bounded cost; a silently skipped review is a missed one.

**Auto-discovery mode only.** Explicit mode names PRs deliberately, and this skill's standing contract is that a named PR always gets a fresh review — do not gate explicit mode on this check. Explicit runs still *write* markers, so concurrent auto-discovery sessions benefit from the work they did.

### Marking

```bash
scripts/mark-reviewed.sh <owner> <repo> <number> --sha <head_sha> --verdict <verdict> --session <id>
```

Mark after publishing and **before** releasing the claim. Marking while the claim is still held means there is no instant where the PR is simultaneously unclaimed and unmarked — precisely the window another session would use to start a duplicate review. Releasing first and marking second reintroduces the gap this ledger exists to close.

Markers older than `PR_REVIEW_DONE_TTL_DAYS` (default 14) are pruned on each write, so the directory does not grow without bound. Pruning is housekeeping only: a stale marker is harmless, since its SHA no longer matches any live PR head.

## Per-PR Loop

For each `(owner, repo, number)` tuple, in shuffled order:

### Step 1 — Claim

```bash
scripts/claim-pr.sh <owner> <repo> <number> --session <id>
```

This comes first, before the pre-check and before any `gh` call against the PR — claiming is cheap, and holding the claim while inspecting the PR keeps two sessions from both doing the inspection. On `"claimed": false`, record `SKIPPED: claimed-elsewhere` and go straight to the next tuple: no pre-check, no review, no release. See "The Claim Ledger" above for the full response contract.

### Step 2 — Pre-check

```bash
scripts/pre-check-pr.sh <owner> <repo> <number>
```

Prints `{"skip": bool, "reason": "merged"|"closed"|null, "draft": bool, "title": string, "head_sha": string}`. Keep `head_sha` — Steps 3 and 6 both need it.

- `skip: true, reason: "merged"`: **skip**. The PR has already merged — reviewing it now provides no value. Record the skip with reason `merged`, and release the claim taken in Step 1.
- `skip: true, reason: "closed"`: **skip** the same way, reason `closed`, releasing the claim.
- This check runs even for auto-discovered PRs, which are already filtered to open state at discovery time — it exists to catch a PR merging *between* discovery and actual review (a real race across a multi-PR batch), and it's the only state check explicit-mode PRs get at all, since a user-supplied number has no prior filtering.
- `skip: false`: proceed. If `draft` is `true`, proceed normally in either mode — a named PR is explicit intent, and a discovered PR was actually requested for review, so draft status alone is not a reason to skip. Note `draft` in the ledger line so it's visible in the final table.
- If the script itself fails (bad PR number, no access, repo typo): treat as this PR's first failure (see Failure Handling below), not a reason to abort the batch.

### Step 3 — Already-Reviewed Check (auto-discovery mode only)

```bash
scripts/check-reviewed.sh <owner> <repo> <number> --sha <head_sha>
```

On `"reviewed": true`, another session (or an earlier run) already reviewed this exact commit: release the claim, record `SKIPPED: already-reviewed`, and move to the next tuple. Skip this step entirely in explicit mode — see "The Reviewed Ledger" above for why a named PR is always re-reviewed.

### Step 4 — Review

Invoke `my-review` (via the `Skill` tool) in PR mode, targeting this PR. Let it run its full flow — mode routing, lens fan-out, adversarial-debate on findings, verdict. Do not shortcut or summarize its inputs; it needs the real PR context to build its `existing_comments_index` and dedupe correctly.

### Step 5 — Publish

Immediately invoke `publish-review` (via the `Skill` tool) for the same PR. Per this skill's own convention ("Invoking this skill is the approval — publish immediately without asking for confirmation"), and per `pr-review-loop`'s own contract that invoking the loop is the batch's standing approval, do not pause for a separate per-PR confirmation here.

**Why no extra dedup step is needed.** The loop always re-reviews every PR, even ones reviewed before at the same commit. This is safe against duplicate noise because `my-review` already builds an `existing_comments_index` (file/line/substance/thread-root) before its lens reviewers run, dedupes new findings against it during merge, and explicitly treats a PR with the reviewer's own prior pass as a re-review ("re-read the full diff and all comments... where authors may explain what changed"). `publish-review` separately validates every reply target against current comment state. Between the two, a repeat run over the same PR list should surface only genuinely new findings, not restate old ones — verify this holds by skimming `my-review`'s findings for repeats of clearly-already-addressed items before publishing; if dedup ever visibly fails, that's a `my-review` gotcha to capture, not something to patch inside this loop.

### Step 6 — Mark Reviewed, Then Release

```bash
scripts/mark-reviewed.sh <owner> <repo> <number> --sha <head_sha> --verdict <verdict> --session <id>
scripts/release-pr.sh <owner> <repo> <number> --session <id>
```

Order matters: mark first, release second. Between the two calls the PR is still claimed, so no other session can slip in and start a review of a commit that has just been reviewed but not yet marked.

Mark on any path where a review actually happened, including a `COMMENT` verdict — an unapproved PR stays in `discover-review-queue.sh`'s output forever, so the marker is the only thing stopping every subsequent session from reviewing it again. Do **not** mark a PR skipped as merged/closed or one that failed before producing a verdict; nothing was reviewed, and a marker would suppress a future legitimate review.

Then release, whatever the outcome. Expect `{"released": true}`; a `"reason": "not-claimed"` means the claim was already gone (a TTL steal, or manual cleanup) and is worth noting in the ledger line, since it implies another session may have been reviewing the same PR concurrently.

### Step 7 — Record and Checkpoint

Append one ledger line:

```
- PR #<number> (<owner>/<repo>)<, draft if applicable> — <verdict> — published: <event> (<N> inline, <M> replies) — <url>
```

or, for a skip/failure:

```
- PR #<number> (<owner>/<repo>) — SKIPPED: <reason>
- PR #<number> (<owner>/<repo>) — SKIPPED: claimed-elsewhere (holder <id>, <N>m old)
- PR #<number> (<owner>/<repo>) — FAILED after <k> attempts: <error/root cause>
```

Per `context-checkpoint.md`: once this line is recorded, the full findings text, diff, and any subagent transcripts from Steps 4-5 for this PR are no longer needed. Do not re-quote them when starting the next PR — carry forward only the ledger.

## Failure Handling — Three Strikes, Scoped Per PR

Apply `loop-detection.md`'s rule to each PR independently, not to the batch as a whole:

1. **First failure** (any step): diagnose — check `gh auth status`, confirm the PR number/repo resolved correctly, check for an obvious transient error (rate limit, network) — and retry once with the fix applied. Retrying is safe with the claim still held: re-claiming from the same session returns `"reclaimed": true` rather than blocking.
2. **Second same-root failure**: one more targeted retry.
3. **Third same-root failure**: stop attempting this PR. **Release its claim** (Step 6), then record it as `FAILED` with the repeated error and a best root-cause theory. Move on to the next PR in the list — a stuck PR never blocks the rest of the batch, and a stuck PR still holding its claim would block every other session too.

A failure must never leave a claim behind. If the run itself aborts mid-PR, the TTL is the backstop, not a plan — on the next run, note any claim file older than the TTL that belongs to a dead session.

## Final Report

After the last PR (or after the list is exhausted, however many were skipped/failed), print the full ledger as a table, plus counts: processed / published / skipped / failed. Call out every skip and failure by number so nothing silently drops off the list. Report the run's session id, and break out `claimed-elsewhere` and `already-reviewed` skips separately from `merged`/`closed` ones — the first two mean another session covered the PR, not that it needed no review. Confirm no claim from this session is left in the claims directory.

A run in which most PRs come back `claimed-elsewhere` or `already-reviewed` is not a failed run: it means the other sessions got there first, which is the coordination working. Say so plainly rather than reporting it as zero work done.

## References

- `scripts/discover-review-queue.sh` — auto-discovery mode's backing script; runs independently of this skill for spot-checking (`scripts/discover-review-queue.sh`, no arguments).
- `scripts/shuffle-queue.sh` — randomizes stdin lines; used on the working list in both modes. Set `PR_REVIEW_SHUFFLE_SEED` for a reproducible order.
- `scripts/claim-pr.sh <owner> <repo> <number> [--session <id>]` — Step 1's atomic claim against the shared ledger.
- `scripts/release-pr.sh <owner> <repo> <number> [--session <id>] [--force]` — Step 6's claim release.
- `scripts/pre-check-pr.sh <owner> <repo> <number>` — Step 2's merged/closed check, used for every PR in both modes; also the source of `head_sha`.
- `scripts/check-reviewed.sh <owner> <repo> <number> --sha <sha>` — Step 3's already-reviewed-at-this-commit gate (auto-discovery mode only).
- `scripts/mark-reviewed.sh <owner> <repo> <number> --sha <sha> [--verdict <v>] [--session <id>]` — Step 6's reviewed marker, written before the claim is released.

Two ledger directories, distinct lifetimes: `~/.claude/thoughts/shared/pr-review-claims/` holds a file only while a review is in flight, and `~/.claude/thoughts/shared/pr-review-done/` keeps a per-PR marker of the last commit reviewed (pruned after 14 days).
