# Protocol — my-review

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Code Review

Perform a thorough, high-quality code review. Works on local changes (unstaged/staged/committed) or GitHub pull requests.

This skill is the **orchestrator**. It dispatches focused research only for
unanswered facts, then one whole-diff reviewer that applies every activated
coverage checklist in retained context. It owns triage, deduplication, targeted
questions, isolated per-finding verification, whole-review challenges, the
verdict, and pattern capture.

## Getting Started

Determine what to review:
- If `$ARGUMENTS` is `capture` → **Capture Mode** — load `references/learned-miss-lifecycle.md`, queue a Learned Miss, and skip the rest of this skill.
- If `$ARGUMENTS` is `promote` → **Promote Mode** — load `references/learned-miss-lifecycle.md`, walk the pending queue, and skip the rest of this skill.
- If `$ARGUMENTS` contains a PR number or URL → **PR Mode** (fetch the PR diff via `gh`).
- If `$ARGUMENTS` contains a Linear issue identifier or URL → **Local Issue Mode** — review the local branch-wide diff with that issue's context.
- If `$ARGUMENTS` is empty or `local` → **Local Mode** (review the whole branch: every commit since the base branch, plus staged and unstaged changes).
- If `$ARGUMENTS` contains a branch name → same as Local Mode, with that branch as the base instead of the detected default.

Subcommand keywords (`capture`, `promote`) take precedence over branch-name interpretation.

Resolve `review_relationship` before verdict construction:

- Local, branch/range, Local Issue, and embedded local reviews → `local`.
- PR author login equals the authenticated GitHub login → `self_authored_pr`.
- PR author login differs from the authenticated GitHub login → `third_party_pr`.
- Either login cannot be established → `unknown_pr`.

Only `third_party_pr` is eligible for `COMMENT`.

### Read before output

- `gotchas.md` — known failure patterns for this skill.
- `references/learned-miss-lifecycle.md` — run the auto-promotion check.
- `references/learned-misses.md` — active pattern queue. Auto-promote qualifying pending entries before the triage block.

Before selecting scope, discover the ledger in Claude Thoughts and, when found,
follow `references/finding-ledger.md`.

## Step 1 - Gather Diff Existing Feedback

**PR Mode - read-only via `gh`, never check out branch.**

PR scope is the aggregate merge-base-to-HEAD diff: all net PR changes, never individual commits. The local tree is not PR truth.

**Hard constraints:**

- Never run `git checkout`, `git switch`, `gh pr checkout`, or fetch PRs into named local branches.
- Never read PR-changed files from local disk and treat them as PR code.
- Never compare PR against local `main` as substitute for the PR diff.
- Read PR code only via `gh pr diff <number>` and PR HEAD contents.

```bash
gh pr diff <number>
gh pr view <number>
gh pr view <number> --json files --jq '.files[].path'
gh pr view <number> --json author --jq '.author.login'
gh api user --jq '.login'

sha=$(gh api repos/{owner}/{repo}/pulls/<number> --jq '.head.sha')
gh api repos/{owner}/{repo}/contents/<path>?ref=$sha --jq '.content' | base64 -d
```

`gh pr diff <number>` is the only PR review range. Never review commits independently or compare PR HEAD directly with current `main`.

Fetch existing review comments and conversation threads using `~/.claude/rules/pr-cost-control.md`: GraphQL `reviewThreads` first for inline comments/resolved/outdated state, then filtered REST fallbacks for review bodies and issue comments. Do not ingest raw `gh api` review/comment payloads.

Build `existing_comments_index`: file path, line range, substance summary, `thread_root_id`. Pass it to reviewer subagents for dedupe and use it again when merging findings.

Build one fingerprinted review bundle: source/range, manifest, full aggregate
diff, requirements/delivery context, comment index, and a short
`relevant_patterns` excerpt matched to diff triggers. Reuse stable auxiliary
evidence until its fingerprint changes; see `evidence-bundles.md`. The cache
never narrows scope: every pass reviews the full aggregate change from the
original merge base to current HEAD.

Compare the PR author's login with the authenticated GitHub login to resolve
`review_relationship`. A missing login is `unknown_pr`, never an assumption that
the PR belongs to someone else.

If existing comments include your own prior pass, re-read the full aggregate
diff and all comments, including issue-level threads. Reuse only fingerprinted
requirements, project, dependency, and prior-disposition evidence.

**Local Mode:**

Review the whole branch: merge base to HEAD plus staged and unstaged changes.

Resolve the base branch, then diff from the fork point:

```bash
base="$ARGUMENTS_BRANCH"   # explicit base from $ARGUMENTS, else detect:
[ -z "$base" ] && base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
[ -z "$base" ] && { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }

# A branch is never its own base — that silently collapses the scope to uncommitted work.
cur=$(git rev-parse --abbrev-ref HEAD)
[ "$base" = "$cur" ] && [ "$cur" != main ] && [ "$cur" != master ] && \
  { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }

# Prefer the remote ref — a stale local base yields a fork point that is too new,
# which silently drops branch commits from the review.
base_ref="$base"
git show-ref --verify --quiet "refs/remotes/origin/$base" && base_ref="origin/$base"

fork=$(git merge-base "$base_ref" HEAD)

git log --oneline "$fork"..HEAD   # every commit added on this branch
git status --short                # uncommitted work
git diff --stat "$fork"           # scope check: branch commits + staged + unstaged
git diff "$fork"                  # THE REVIEW DIFF
```

`git diff "$fork"` is the review diff. Pass it as `diff_text` with `base_ref`/`fork` so every reviewer uses the same range.

Hard constraints:

- Never use `git show HEAD`, `git diff HEAD~1`, `git log -1`, bare `git diff`, or `git diff --cached` as scope; each omits part of the branch.
- If `$fork` resolves to `HEAD` (you are on the base branch, or the branch has no commits yet), `git diff "$fork"` correctly narrows to uncommitted work. Say so in the triage block rather than widening the scope on your own.
- If the resulting diff is empty, report that there is nothing to review. Do not substitute a narrower or older scope to have something to say.
- Never `git diff "$base_ref" HEAD`; resolve and use `fork`, even after origin refreshes the base.

State `base_ref`, commit count, and changed-file count in triage.

Research subagents and the whole-diff worker read changed files fully when
needed.

## Step 2 — Cursory Pass: Identify Coverage Criteria

Select the applicable review **lenses** as coverage criteria for the one
whole-diff worker and its deep-dive sections; they never select specialist
reviewer agents in ordinary `my-review`.

### Inputs

- PR description, commit messages
- Linked Linear issue(s), referenced specs / RFCs / design docs (fetch them — don't infer)
- File-level scan of the diff: which areas changed? (backend / frontend / migrations / config / infra / tests / docs / dependency manifests)
- Existing reviewer assignments or labels on the PR

Read `references/review-contract.md` before choosing lenses.
Read `references/change-set-risk.md` before dispatch; classify the aggregate diff
and build the mode-specific human-acknowledgement item from its deterministic triggers.
Read `references/incremental-delivery.md` and resolve the current change's
promised increment before building the requirements checklist or choosing a
requirements verdict.

### Lens catalog

| Lens | Scrutinizes | Trigger signals |
|---|---|---|
| **Backend** | Data integrity, query performance, idempotency, error handling, transactions, race conditions, job safety | Server-side code, contexts, schemas, queries, jobs, workers |
| **Frontend** | Accessibility, responsive behavior, state management, render performance, UX consistency, design system adherence | UI components, hooks, stores, CSS, design tokens |
| **Full-stack** | Backend + Frontend with cross-layer wiring scrutiny | Both areas touched in one change |
| **Security** | Auth/authz, input validation, injection vectors, secrets, CORS/CSP, token handling | Auth code, input handlers, queries with user input, file upload, external API creds, security headers |
| **Architecture** | System boundaries, coupling, abstraction quality, scalability, contract design, migration paths | New modules/services, changes to module boundaries, new dependency directions, new infra patterns |
| **Ops** | Deployment safety, observability, failure modes, rollback paths, resource usage, configuration | Health checks, logging, feature flags, config files, deploy manifests, env vars, resource limits |
| **QA** | Test fidelity, coverage gaps, assertion quality, flakiness, test architecture | Test files added/modified, mocks/stubs, new modules without tests |
| **PM** | Requirements coverage, acceptance criteria traceability, scope creep, user-facing behavior | Linked ticket with detailed acceptance criteria, new user-facing behavior |
| **Performance** | Hot-path queries, N+1, caching, indexes, unbounded loops, large-table queries | Queries on large tables, hot endpoints, queue/concurrency changes, caching logic |
| **Migration safety** | Lock risk, down-migration safety, column types, advisory locks, backfillers | Migration files in the diff |
| **Dependency** | License, maintenance, attack surface of new packages | Lockfile changes, new dependency manifests |

Except for the Low-risk fast-approval path, `general-reviewer` is the one
whole-diff worker for every non-empty code diff. Security, QA, Architecture,
and Performance are activated coverage criteria only when their concrete trigger
signals fire; record every inactive criterion and its diff-based reason in the
Coverage Manifest.

### Requirements checklist (if a ticket is linked)

Fetch a supplied Linear ticket into `requirements_checklist`; otherwise infer an
issue identifier from the branch name before declaring it unavailable. Activate
the PM lens when a checklist exists.

If a caller supplies a **spec, living workflow ledger, or requirements
document** directly (for example, `my-workflow` passes its synchronized ledger),
read it and build the `requirements_checklist` from its Requirements, Scope, and
Need Summary sections. A direct planning document is an equally valid
requirements source and takes precedence when both it and a ticket are present.
Activate the PM lens whenever any requirements source exists.

The checklist describes the eventual need. Classify its criteria against
`delivery_increment` as Included now, Foundation for later integration,
Deferred to a later increment, or Unclear. Only Included-now criteria are
required to be complete in this change. A partial or non-user-facing increment
is eligible for approval under `references/incremental-delivery.md`.

### Linear project context

For a project ticket, read `references/project-context.md` and build
`project_context` before dispatch. It informs duplicate non-Critical follow-ups
only; planned work never accepts a current gap or Critical defect.

### Tracer triggers

Set `tracer_triggers.neighbor_commits_heuristic = true` if any of the diff's changed files appear in commits whose messages reference a closed Linear issue from `git log --since=60.days --name-only --pretty=format:'%H %s'`. This is the only signal that needs main-context git access — the others (PM lens active, ticket linked, requirements-audit escalated) are already known from triage.

### Plan-file lookup

Check `~/.claude/thoughts/shared/plans/` for a plan file matching the linked Linear ticket (filename or `feature:` frontmatter). If found, read the plan's surfaces (Phase sections, "Changes Required" lists, "What We're NOT Doing") and hold them as `plan_surfaces` — you'll pass them to `requirements-tracer` if it runs in Step 3.

### Triage output

Produce a short triage block and show it to me before going deep:

```
### Review Triage
- **Scope:** <PR #N at <sha>> | <local: <N> commits since `<base_ref>` (<fork sha>) + <clean tree | staged/unstaged changes>>, <N> files
- **Intent:** <1–2 sentences in your words — what this change does and why>
- **Delivery increment:** <what this change promises now; whether it is user-facing; deferred integration or handoff>
- **Overall change-set risk:** <Low | Medium | High> — <diff-grounded rationale>
- **Human acknowledgement:** <PR: one inline anchor + trigger/anchor count; operational readiness confirmed|required|not applicable> | <local pre-stage: clear | N acknowledgements required, with accepted advisory and confirmed operational scope> | none
- **Lenses identified:**
  - <Lens> — <one-line rationale grounded in the diff>
  - <Lens> — <one-line rationale grounded in the diff>
- **Requirements checklist:** built from <ticket ID> | none linked
- **Coverage:** <required lenses and skip reasons>
- **Project context:** <project name> — <N> active/upcoming siblings checked; <N> exact follow-up matches | none
- **Tracer triggers:** <list which fired, or "none">
- **Author calibration (PR Mode):** <Junior | Mid | Senior | Lead | Staff+> — see below
- **Auto-promoted since last review:** <count> · <target file(s) + Shape one-liner(s)> (or "none")
- **Pending learned misses:** <count> (run `/my-review promote` to triage early)
```

To populate the last two lines:
- Pending count = entries with `status: pending` or `status: ready` under `learned-misses.md`'s `## Pending`.
- Auto-promoted-since-last-review = entries under `promoted-misses.md`'s `## Promoted` whose `status: promoted (<date>)` is newer than the last completed review. If you can't determine the prior review timestamp, list any promotion dated within the last 14 days.

If `status: ready` entries exist (auto-promote blocked on ambiguous target), call them out by name — these need your input.

Proceed automatically unless I override.

If the aggregate set qualifies for `change-set-risk.md`'s Low-risk fast
approval, stop here after the required scope, requirements, thread, and trigger
checks. Return the terse approval directly; Steps 3–8 do not run.

### Local pre-stage human-acknowledgement checklist

Before Step 3 in any local mode, apply `change-set-risk.md`'s local checklist
exactly. Uncovered trigger scope is review item 1. Keep advisory acknowledgement
separate from operational confirmation for environment variables, feature
flags, and migrations. Continue the review pipeline and return the substantive code verdict
in the same pass. Outstanding checklist items never withhold local `APPROVE` or
manufacture `REQUEST_CHANGES`. Accepted scope suppresses only the matching
repeat item, never ordinary defect analysis.

### Author Skill Level (PR Mode only)

Load `references/author-calibration.md`. Skip this step in Local Mode.

## Step 3 — Dispatch Research and the Whole-Diff Worker

You orchestrate in two waves: focused research first when a fact is unanswered,
then exactly one `general-reviewer` that reviews the full aggregate diff against
all activated coverage criteria. The worker retains the full context and returns
one consolidated finding set; this skill performs the bounded synthesis.

### PR Mode — Hard Constraints, propagated to every subagent

Subagents will silently read on-disk files unless told not to. In PR mode you
MUST paste this block verbatim into every research, whole-diff-worker, and
verifier prompt:

```
PR Mode Hard Constraints. The PR diff is the source of truth; the local working tree is NOT (main often lags remote, and the PR branch may not exist locally).
- Scope is the aggregate merge-base-to-PR-HEAD diff, never individual commits or PR HEAD directly against the current base tip.
- NEVER run git checkout/switch, gh pr checkout, or git fetch origin pull/N/head:<name> — nothing that changes the working tree or creates a local branch ref.
- NEVER read PR-changed files from disk (Read/cat/grep) and treat the result as the PR's code — that reads main, not the PR.
- NEVER compare the PR against local main as a substitute for the diff.
- Read PR code ONLY via: the supplied diff_text, and `gh api repos/{repo}/contents/{path}?ref={pr_head_sha}` for full file contents at PR HEAD.
- NEVER fetch or report CI/check status — no `gh pr checks`, GitHub Actions runs, or RWX/CircleCI pipelines. CI reports its own findings; your job is the diff.
- Read unchanged code only for impact. A finding needs a `diff_text` anchor and causal link showing the PR introduced, regressed, or exposed it. Do not report or publish baseline-only defects.
```

### Wave 1 — Research subagents (parallel, one message)

Spawn only specialists needed for an unanswered question:

- **codebase-analyzer** — unresolved control/data-flow question.
- **codebase-pattern-finder** — new behavior, extraction, or suspected duplication.
- **docs-researcher** — new dependency or uncertain version-specific API/framework behavior.
- **requirements-tracer** — spawn only if any `tracer_triggers` flag is true. Pass `mode: review`, `scope: wide`, the primary Linear issue ID (if any), the PR number, and `plan_surfaces` if present (it diffs predicted-vs-actual and only re-runs related-issue discovery if they differ meaningfully).

Collect their outputs into a **compact `research_notes` summary** — the load-bearing facts (call chains, duplication hits, doc gaps), not raw dumps. This is what you hand to the whole-diff worker.

### Wave 2 — One whole-diff reviewer

For every non-empty review that did not take the Low-risk fast-approval path,
dispatch exactly one `general-reviewer`. It is the Sonnet whole-diff worker, not
a lens-specific pass: give it the full aggregate diff, changed-file manifest,
requirements and delivery context, existing-comment index, compact research
notes, trigger-matched patterns, and the complete list of activated coverage
criteria (the activated criteria). Never substitute lens-specific excerpts or selective hunks for the
full diff.

In local mode, `base_ref` and `fork_sha` are the values resolved in Step 1, and `diff_text` is `git diff "$fork"`. Passing both means a reviewer that widens its own diff reproduces the branch-wide range instead of falling back to the working tree or the last commit. Research subagents get the same two values for the same reason.

The worker applies the general checklist plus each activated specialist checklist
in one retained context. The specialist agents remain available to their
standalone audit workflows, but ordinary `my-review` does not dispatch them.
It dedupes against `existing_comments_index` and returns one consolidated flat
findings set with any applicable deep-dive or requirements-traceability blocks.

### Wave 3 — Compile

Compile the whole-diff worker's findings set:

1. **De-duplicate** the worker's findings by line and substance, retaining the most precise framing and all applicable coverage-area attribution.
2. **Re-check dedupe against `existing_comments_index`** — a reviewer may have missed a thread; drop or `add_to_thread` anything already raised.
3. **Assemble** one flat findings set — each finding keeping its `Severity`, `Risk`, `Confidence`, and coverage-area attribution — plus applicable deep-dive subsections and related-issue risks.
4. **Sanity-check coverage**: the one worker accounted for every activated coverage criterion. If it returned an error or omitted a clearly applicable area, re-dispatch it once with a tightened brief; do not silently drop it.

Before verifier dispatch, drop and record candidates that duplicate a thread,
lack an anchor/causal link, or lack a concrete author-controlled action,
decision, or information request. Do not send observations or general advice to
a verifier.

This compiled set is what Steps 4–8 operate on.

## Step 4 — Targeted Questions

If any compiled finding carries `Severity: Question`, ask it. The point is to catch things where the situation depends on context only I have.

### After I answer — challenge my answers

Once I respond, use **adversarial-screen** to challenge the answer. Do not
escalate a decision challenge to Sol; a material risk becomes a finding and
follows the normal Critical/High-risk verifier route.

Pass `mode: decision`, the current review-bundle fingerprint, and only the
question, answer, and cited context needed to test it.

Pass to the agent:
- The original question + the investigation context that surfaced it (diff, relevant files, the compiled findings)
- My answer

The screen returns one of `PASS`, `REVISE`, `ESCALATE`, or `NEEDS_EVIDENCE`.

Apply the result:
- PASS → record the answer and proceed.
- REVISE → correct the factual mismatch and ask one follow-up question if it remains load-bearing.
- ESCALATE or NEEDS_EVIDENCE → record the gap as a Question. Route it to Sol
  only if it establishes a concrete Critical or High-risk finding.

### When to skip

If no compiled finding carries `Severity: Question`, skip this step entirely.

If I've authorized auto-mode (or said "no questions, just review"), log these as a **Questions** section in the final review output (Step 5) instead of pausing. The post-answer adversarial pass is also skipped in this mode — there are no answers to challenge.

## Step 5 — Format the Review

Load `references/review-output.md` and render the compiled findings, human
handoff, approval status, and Step 7 verdict in that exact shape.

## Step 6 — Whole-Diff Synthesis and Per-Finding Verification

Read `references/review-contract.md` and run its bounded synthesis pass before
verifier routing. Synthesis candidates enter the normal verifier route; they
never change a verdict directly.

The complete Sonnet whole-diff review is the default evidence pass. Verification is exceptional and isolated: it may deepen an eligible high-impact finding or resolve an explicitly named fact whose answer could change the verdict or Opus eligibility. Do not automatically verify every finding.

### Route each finding to a tier

Read `references/finding-axes.md` and compute the tier mechanically from the finding's three levels:

```
finding-verifier-high  if (severity == Critical OR risk == High) AND confidence >= 80
finding-verifier-low   only if verification_need == needs_confirmation, with a named unresolved fact, exact verification query, and a code-verdict or Opus-eligibility routing consequence
```

An unchecked causal prerequisite caps confidence at 79, preventing an Opus escalation until evidence exists. All other findings remain explicitly unverified and cannot affect the verdict.

### Dispatch

Dispatch eligible Opus candidates in parallel. Dispatch targeted Sonnet candidates only when they meet every `needs_confirmation` condition; all other findings remain not independently verified. Pass each verifier:

- `mode`, and the PR diff or local diff source of truth (plus `pr_head_sha`/`repo` and the PR-mode constraints block in PR mode)
- that finding's file paths and lines only
- the finding's claim, diff anchor, changed-line causal link, severity, risk, numeric confidence, evidence, and proposed fix
- for targeted Sonnet only: `needs_confirmation`, named unresolved fact, exact verification query, and routing consequence
- requirements checklist, if present and relevant to that finding
- **nothing about the other findings** — each dispatch verifies its own claim in isolation so no verdict can be biased off a sibling

High-tier returns KEEP, DOWNGRADE, DROP, REVISE, PROMOTE, or `requires clarification`. Low-tier returns the same minus PROMOTE, plus `requires clarification`. Both must cite evidence (`file:line`, or `source` + `query` + `retrieved-at`).

### Handle targeted-Sonnet uncertainty

A targeted-Sonnet `requires clarification` becomes a targeted question. Re-route only a `REVISE` supported by evidence that satisfies the exact Opus predicate.

Never treat uncertainty as a DROP. A high-tier `requires clarification` is a
question, not a loop (see `~/.claude/rules/loop-detection.md`).

### PR mode caveat

Verifier agents can accidentally read the local working tree. If any DROP or REVISE rests on "file does not exist," "identifier is fabricated," or "function cannot be found," verify against the PR diff or PR HEAD before applying it — a PR that adds a file means the file is real and just isn't checked out.

### Apply verdicts

- KEEP: present as-is.
- DOWNGRADE: apply the verifier's revised levels.
- REVISE: update claim, levels, or fix.
- DROP: remove and note in Dropped Findings.
- PROMOTE: raise to the stated severity, citing the verification evidence. This is **mechanical, not discretionary** — a finding PROMOTEd to Critical carries into Step 7 at its verified risk level; it requests changes only when that risk is also High.
- `requires clarification`: surface as a Targeted Question naming the exact query a human should run. Never silently drop it, and never fill the gap with a guess presented as verified.

Before `/this-important`, use `references/project-context.md` to remove only exact non-Critical follow-ups in **Upcoming Project Work**. Title-only/partial matches, gaps, and Critical findings remain.

Apply `references/review-contract.md`'s Actionability Gate to every surviving
finding and question. Each must request a concrete author-controlled code, test,
or documentation change; an explicit product/scope decision; or specific
information needed to resolve a changed-line risk. Drop observations,
preferences, generalized advice, speculative future concerns, and open-ended
questions. Do not move rejected material into residual risk, deep-dive prose, or
Nits.

Run `/this-important strict` (unless the user asked for a broader sweep) on remaining unverified non-blocking findings. It has no PROMOTE verdict and must not downgrade an Opus-verified KEEP or PROMOTE.

Before Step 7, confirm:

- every Opus-eligible candidate got a high-tier verifier; targeted Sonnet work had every required `needs_confirmation` field; all others are labeled unverified
- no finding duplicates an existing PR thread
- every PR finding has an aggregate-diff anchor and causal link; baseline-only issues never survive
- every finding is grounded in the diff or verified source
- every surfaced finding and question passes the Actionability Gate; deep-dive and residual-risk sections do not smuggle rejected commentary back in
- every `REQUEST_CHANGES` candidate is both Critical and High risk, and truly
  blocks the declared increment rather than merely belonging to the eventual
  feature
- dropped findings have one-line reasons
- every targeted-Sonnet uncertainty is surfaced as a question, or was re-routed only after cited evidence satisfies the exact Opus predicate
- every `requires clarification` finding is surfaced as a question, not silently resolved either way
- every actionable finding without independent verification is labeled `not
  independently verified` and is verdict-neutral
- the Coverage Manifest and final integrity gate in `review-contract.md` passed
- overall change-set risk was classified independently from per-finding risk
- a required PR human acknowledgement is one deduplicated inline annotation, not
  repeated in the review body, questions, findings, or residual risk; a
  deduplicated request is not readiness confirmation
- local advisory and operational scopes use their separate stable keys; an
  older generic acceptance never confirms environment, feature-flag, or
  migration readiness
- In PR mode, `APPROVE` is absent whenever any operational-readiness tuple is
  unconfirmed. In local mode, the code verdict is always present and the same
  tuple is reported under pre-stage human acknowledgement.

## Step 7 — Verdict

The verdict is a **mechanical function of Step 6's verifier results and the
resolved review relationship**, not a fresh judgment call layered on top.

The Low-risk fast-approval path has already returned before this step. A
human acknowledgement is not a defect and cannot produce `REQUEST_CHANGES` by
itself. Local reviews always compute `code_verdict` independently: a verified
Critical, High-risk blocker produces `REQUEST_CHANGES`; otherwise return
`APPROVE`, even when pre-stage human checks remain. In PR mode, if any
environment-variable, feature-flag, or migration readiness tuple remains
unconfirmed, set `status: needs_input` and
`approval_status: pending_human_confirmation`. A third-party PR may use
`COMMENT`; self-authored and unknown-ownership PR reviews return no verdict.
Never use PR `APPROVE` until the exact operational scope is confirmed.

- If any finding is both post-verification `Critical` (KEPT Critical, or PROMOTEd to Critical) **and** `High` risk → **REQUEST_CHANGES**, full stop. Do not re-litigate whether it is merge-blocking — Step 6 independently verified it with cited evidence. A Critical finding at Medium or Low risk is still presented prominently, but follows the normal non-blocking verdict rules. A finding that needs clarification is never an automatic request for changes; surface it as a blocking question instead.
- Otherwise, in PR mode, if operational readiness is pending, apply the pending
  state above.
- Otherwise apply the mode gate:
  - **Local, branch/range, Local Issue, or embedded local:** **APPROVE** with any outstanding pre-stage human-acknowledgement items shown separately. Keep actionable non-blocking findings and targeted questions visible, but do not turn them into `COMMENT` and do not inflate them into blockers merely to avoid approval.
  - **Self-authored PR or unknown PR:** **APPROVE** after operational readiness is confirmed. Keep actionable non-blocking findings and targeted questions visible.
  - **Third-party PR:** **APPROVE** when the declared increment's requirements are satisfied and every remaining finding is Low risk (including substantive actionable feedback). Use **COMMENT** when Medium/High-risk non-blocking feedback, unresolved increment/requirements context, stale/already-merged PR state, or explicit user instruction not to approve remains.

`COMMENT` is invalid unless the review targets an actual PR and its author login
is known to differ from the authenticated reviewer's login.

### Challenge the eligible verdict choice

`REQUEST_CHANGES` is not up for debate in this pass once Step 6 has verified a Critical, High-risk finding. A pending PR operational-readiness state is likewise mechanical, so do not challenge it. For a third-party PR only, the remaining APPROVE/COMMENT choice after readiness is confirmed is discretionary and receives a Terra adversarial screen. Local, self-authored PR, and unknown-PR reviews have no COMMENT branch, so skip the pass after confirming no Critical High-risk blocker survived. Spawn `adversarial-screen` with:

- `mode: decision` and the current review-bundle fingerprint;

- proposed APPROVE/COMMENT verdict
- the final surviving non-blocking findings, with their risk and confidence levels
- triage context and active lenses

Ask it to challenge:

- Is COMMENT actually warranted, or are all remaining findings Low risk and therefore compatible with APPROVE?
- Is APPROVE overstating confidence because a finding is Medium/High risk or a requirements/context question remains?

Apply the adversarial verdict before final output.

## Step 8 — Re-review Pattern Capture

Only fires when Step 1 detected existing review comments from your prior review pass on this PR. Skip entirely otherwise.

After the verdict is finalized, look at any PR comments (from other reviewers or the author) that surfaced since your last pass:

1. Classify each: `Already-flagged-by-you` / `Out-of-scope` / `Worth-considering`.
2. For the `Worth-considering` set, ask one batched question:
   > "Do any of these point to a pattern the skill should have caught? [numbers or 'none']"
3. For each selected comment:
   - Check `references/learned-misses.md` and `references/promoted-misses.md` for an existing matching Shape; append a new Evidence entry (`type: missed`, today's date, `ref` = comment link) if found.
   - Otherwise, draft a Shape and Trigger signals, confirm with me, then append a new entry under `learned-misses.md`'s `## Pending` with `status: pending`.

If no `Worth-considering` items, skip the prompt entirely.

## Guidelines

- Every Critical finding must include a concrete fix, ideally replacement code. Only Critical findings with High risk are merge-blocking.
- Classify the aggregate change set before rating findings. A genuinely Low-risk
  set is approved immediately; line count alone never establishes Low risk.
- In PR mode, migrations, environment variables, feature flags, other config,
  infra/ops changes, added linter/tooling suppressions, and modifications to
  existing test files require exactly one deduplicated inline human
  acknowledgement for the whole PR. New test files do not trigger it.
- In local mode, apply `change-set-risk.md`'s ledger-deduped first-item pre-stage
  checklist; never infer or auto-accept readiness. Environment-variable,
  feature-flag, and migration readiness uses its separate stable key but never
  suppresses the code verdict.
- Every non-blocking suggestion should include example code when the alternative is not obvious.
- Raise only actionable feedback. Every finding or question must name a concrete author-controlled change, decision, or specific information request and the changed-line risk it resolves. Drop observations, preferences, generalized advice, and speculative future concerns.
- Explicitly label severity on every comment: **Critical**, **Suggestion (non-blocking)**, **Question**, or **Nit**.
- Ask rather than demand when the author may have context you lack.
- Focus on substance; do not bikeshed formatting, naming, or style unless genuinely confusing.
- Cross-service boundaries deserve extra scrutiny because subtle bugs hide there.
- Tests must test what they claim; vacuous tests are worse than no tests.
- Never re-raise an issue already present in the PR conversation.
- Reserve `REQUEST_CHANGES` for verified Critical **and High-risk** merge blockers: likely production breakage, data loss/corruption/exposure, exploitable security/privacy risk, likely runtime contract break, or an omitted must-have outcome promised by the declared increment with likely or wide impact. The eventual feature may remain incomplete or non-user-facing. Raise every other concern only when it is actionable and clearly non-blocking. In local review, approve the code whenever no such blocker survives and report pre-stage checks separately. In self-authored/unknown PR reviews, operational readiness still gates approval. Use `COMMENT` only on a third-party PR when Medium/High-risk non-blocking feedback or unresolved increment/requirements context remains.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The tests pass, so it's fine" | Green tests are necessary, not sufficient — they don't catch architecture, security, or requirements gaps. Read the diff itself. |
| "CI is red, I should dig into why" | Out of scope. CI reports its own findings on its own surface, and `ci-babysit` owns pipeline triage. Checking `gh pr checks` feels diligent but spends the review's budget re-deriving what the author already sees. |
| "Another reviewer blocked on red CI, so CI state is decision-relevant" | Their blocker, not yours. Note it from `existing_comments_index` and move on. This is the specific rationalization that has actually triggered a CI rabbit hole — see `gotchas.md`. |
| "It's a small PR, a light pass is enough" | Diff size doesn't predict risk. A five-line change to auth or a migration deserves the same scrutiny as a five-hundred-line refactor. |
| "This finding is annoying but not really Critical" | Match severity to `review-finding-format.md`'s bar, not to how strongly it feels in the moment. If it doesn't meet a Critical criterion, it's non-blocking — say so plainly instead of inflating it to force a fix. |
| "The author clearly knows what they're doing" | Author competence isn't evidence the diff is correct. Review the code in front of you, not your prior of the author. |
| "I already found a few issues, that's enough" | Stopping early because a quota feels met leaves real findings on the table — finish the lens sweep before triaging. |
| "The PR conversation probably already covers this" | Confirm it actually does by checking `existing_comments_index` — don't silently drop a finding on a hunch. |
| "This is worth mentioning even though there is no concrete action" | Review feedback consumes author attention. If you cannot name the change, decision, or information needed to resolve a present diff-caused risk, drop it. |
| "The env var/flag/migration looks correct in code, so human confirmation is unnecessary" | Repository correctness cannot prove values exist in every staging/production environment or that a migration ran successfully in staging. Keep the readiness request separate from risk. It withholds PR approval, while local review still returns its independent code verdict and lists the pre-stage check. |
| "The linked issue is not complete or user-facing, so this PR cannot be approved" | Review the declared delivery increment. Internal groundwork and partial delivery can merge when the promised slice is coherent, safe, tested, and accurately leaves later integration or handoff outside its scope. |
| "COMMENT vs APPROVE doesn't matter much here" | It is mode-constrained. COMMENT exists only for a third-party PR. Local review always returns a code verdict; self-authored/unknown PR approval still requires operational readiness. |

## References

- `references/finding-axes.md` - severity/risk/confidence definitions and the Step 6 verifier-tier rule. Read by this skill, the whole-diff worker, and both finding verifiers.
- `references/change-set-risk.md` - aggregate risk classification, Low-risk fast
  approval, the single human acknowledgement, and the approval-gating operational
  readiness confirmation.
- `references/incremental-delivery.md` - resolves the current promised increment
  and permits coherent internal groundwork or staged delivery without requiring
  the eventual feature to be user-facing.
- `references/author-calibration.md` - PR-only explanation-depth calibration.
- `references/review-contract.md` - deterministic coverage, evidence, and final-integrity requirements for every review.
- `references/general-checklist.md` - cross-cutting Critical/non-blocking categories. Read by `general-reviewer` (and promotion target cross-cutting patterns).
- `references/cross-service-contracts.md` - checklist for cross-service changes. Read by `general-reviewer`.
- `references/project-context.md` - bounded Linear project context and exact-match follow-up calibration.
- `references/learned-misses.md` - active pattern queue. Auto-promote check runs top invocation; triage block reports promotions.
- `references/promoted-misses.md` - audit archive of promoted/discarded entries, split out of `learned-misses.md` to stay under the reference word-budget cap.
- `references/learned-miss-lifecycle.md` - capture/promote subcommands and queue auto-promotion. Load for those modes and at invocation start.
- `references/team-review-patterns.md` - team-and-community review patterns distilled from multi-developer PR mining pass. Created by separate mining pass; fold only patterns matching the current diff into `relevant_patterns`.
- `gotchas.md` - known failure patterns. This skill selects only entries relevant to the current diff and passes that compact excerpt to the whole-diff worker.

## Gotchas

Read `gotchas.md` before starting work. Pass only trigger-matched excerpts to
the whole-diff worker. Keep main-flow patterns here; pass investigation patterns
only to the relevant research subagent or verifier.

## Never auto-publish

Producing the final review document is the end of this skill's job. **Do not** invoke `/publish-review`, `gh pr review`, or any GitHub-mutating command on your own. Wait for explicit direction ("post it", "looks good, publish", "ship it"). The user may want to edit findings, add context, or hold the review entirely.
