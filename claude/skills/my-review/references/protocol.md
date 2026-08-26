# Protocol — my-review

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Code Review

Perform a thorough, high-quality code review. Works on local changes (unstaged/staged/committed) or GitHub pull requests.

This skill is the **orchestrator**. It fans the work out to subagents — parallel research subagents for deep context, then specialized per-lens reviewer subagents (security, architecture, performance, QA, requirements, and a general reviewer for the rest) — and then does the parts that genuinely need the main window: triage, merging and de-duplicating the lens findings, targeted questions, routing each finding to its verifier, the whole-review adversarial passes, the verdict, and pattern capture. The deep per-lens reasoning happens in the lens subagents, and per-finding verification happens in one isolated verifier per finding; the routing and synthesis happen here.

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

Compare the PR author's login with the authenticated GitHub login to resolve
`review_relationship`. A missing login is `unknown_pr`, never an assumption that
the PR belongs to someone else.

If existing comments include your own prior review pass, treat as re-review: re-read the full diff and all comments, including issue-level threads where authors may explain what changed.

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

Research subagents and lenses read changed files fully when needed.

## Step 2 — Cursory Pass: Identify Review Lenses

Pick applicable review **lenses**. They drive Step 3 reviewers and deep-dive sections.

### Inputs

- PR description, commit messages
- Linked Linear issue(s), referenced specs / RFCs / design docs (fetch them — don't infer)
- File-level scan of the diff: which areas changed? (backend / frontend / migrations / config / infra / tests / docs / dependency manifests)
- Existing reviewer assignments or labels on the PR

Read `references/review-contract.md` before choosing lenses.

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

Security, QA, and a general-reviewer lens (Backend when none is obvious) are
baseline for every non-empty code diff.

### Requirements checklist (if a ticket is linked)

Fetch a supplied Linear ticket into `requirements_checklist`; otherwise infer an
issue identifier from the branch name before declaring it unavailable. Activate
the PM lens when a checklist exists.

If a caller supplies a **spec or requirements document** directly (e.g. `my-workflow` passes the stage-2 spec path, or `$ARGUMENTS` names a spec/PRD), read it and build the `requirements_checklist` from its acceptance criteria the same way — a spec is an equally valid requirements source, and takes precedence when both a spec and a ticket are present. Activate the PM lens whenever any requirements source exists.

### Linear project context

For a project ticket, read `references/project-context.md` and build `project_context` before fan-out. It informs duplicate non-Critical follow-ups only; planned work never accepts a current gap or Critical defect.

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

### Author Skill Level (PR Mode only)

Ask which skill level to calibrate against. Skip for Local Mode.

| Level | Calibration |
|---|---|
| **Junior** | Thorough and educational. Explain *why*. Encouraging on good work. |
| **Mid** | Standard. Explain non-obvious issues. Trust they can implement fixes given a clear problem description. |
| **Senior** | Concise and direct. Focus on subtle bugs and architecture. Skip explanations of well-known patterns. |
| **Lead** | Concise and strategic. Maintainability, team-wide impact, precedent. |
| **Staff+** | Peer review. Systemic impact, cross-team implications, design tradeoffs. Frame as discussion. |

Default: **Lead** if I skip.

Author calibration affects explanation depth only. It never permits feedback
that fails `references/review-contract.md`'s Actionability Gate.

## Step 3 — Fan out, then compile

You orchestrate in two waves: research first (shared context), then specialized per-lens reviewers (parallel), then you merge everything. The deep reasoning lives in the subagents; the synthesis lives here.

### PR Mode — Hard Constraints, propagated to every subagent

Subagents will silently read on-disk files unless told not to. In PR mode you MUST paste this block verbatim into **every** subagent prompt (research and lens reviewers alike):

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

Spawn these so the lens reviewers get shared deep context instead of each re-deriving it:

- **codebase-analyzer** — deep-read the changed files AND their callers/consumers; map call chains, data flow, dependencies.
- **codebase-pattern-finder** — find how similar changes were made elsewhere; specifically whether a utility/function/module already does what new code adds (duplication is a common finding).
- **docs-researcher** — for new dependencies, or APIs/framework patterns used in ways you're not 100% sure are correct (version-specific behavior). Don't review library usage without checking the actual docs.
- **requirements-tracer** — spawn only if any `tracer_triggers` flag is true. Pass `mode: review`, `scope: wide`, the primary Linear issue ID (if any), the PR number, and `plan_surfaces` if present (it diffs predicted-vs-actual and only re-runs related-issue discovery if they differ meaningfully).

Collect their outputs into a **compact `research_notes` summary** — the load-bearing facts (call chains, duplication hits, doc gaps), not raw dumps. This is what you hand to the lens reviewers.

### Wave 2 — Lens reviewer subagents (parallel, one message)

For each active lens from Step 2, spawn its reviewer. Send them all in a single message so they run concurrently. Pass each the bundle: `mode`, `pr_head_sha`, `repo`, `base_ref`, `fork_sha`, `diff_text`, `changed_files`, `research_notes`, `author_calibration`, `existing_comments_index`, `project_context`, the PR-mode constraints block, plus any lens-specific extras.

In local mode, `base_ref` and `fork_sha` are the values resolved in Step 1, and `diff_text` is `git diff "$fork"`. Passing both means a reviewer that widens its own diff reproduces the branch-wide range instead of falling back to the working tree or the last commit. Research subagents get the same two values for the same reason.

| Active lens(es) | Reviewer agent | Extra input |
|---|---|---|
| Security | `security-reviewer` | — |
| Architecture | `arch-reviewer` | — |
| Performance | `perf-reviewer` | — |
| QA | `quality-reviewer` | — |
| PM | `requirements-reviewer` | `requirements_checklist` |
| Backend, Frontend, Full-stack, Ops, Migration, Dependency | `general-reviewer` | `assigned_lenses` (the subset that fired) |

Spawn a reviewer only for lenses that actually fired in triage. Always include `general-reviewer` if any non-specialized lens is active (it also carries the cross-service-contract checks). Each reviewer reads its source-of-truth skill, applies the checklist, dedupes against `existing_comments_index`, and returns a findings fragment.

Each fragment is a **flat** list: each finding has axes per `references/finding-axes.md`, a `File` anchor in `diff_text`, and changed-line causal link, plus its deep-dive block. Reviewers report levels only; Step 6 verifies and filters. Re-dispatch pre-grouped output with the axes file named.

### Wave 3 — Compile

Merge the lens reviewers' fragments into one findings set:

1. **De-duplicate across reviewers.** Two lenses often flag the same line (e.g. security + general on the same input handler). Collapse to one finding, keeping the most precise framing and noting both lenses.
2. **Re-check dedupe against `existing_comments_index`** — a reviewer may have missed a thread; drop or `add_to_thread` anything already raised.
3. **Assemble** one flat findings set — each finding keeping its `Severity`, `Risk`, `Confidence`, and lens attribution — plus the lens deep-dive subsections each reviewer returned (Security Deep-Dive, Architecture Assessment, Performance Deep-Dive, Quality Deep-Dive, Requirements Traceability), and — if the tracer ran — Related-Issue Regression Risks. When collapsing a duplicate, keep the **highest** severity, the **highest** risk, and the **lowest** confidence of the two: a finding two lenses read differently is one to verify harder, not one to average out.
4. **Sanity-check coverage**: every required lens in the Coverage Manifest
   produced a fragment. If a reviewer returned an `## Error` (e.g. missing
   `requirements_checklist`) or came back empty for a lens that clearly applies,
   re-dispatch it once with a tightened brief before proceeding. Do not silently
   drop a lens.

At compilation, reject any candidate that cannot name a concrete
author-controlled change, explicit decision, or specific information request
that resolves a present changed-line risk. Do not keep observations or general
advice around for the verifier to turn into feedback later.

This compiled set is what Steps 4–8 operate on.

## Step 4 — Targeted Questions

If any compiled finding carries `Severity: Question`, ask it. The point is to catch things where the situation depends on context only I have.

### After I answer — challenge my answers

Once I respond, spawn the **adversarial-debate** agent to challenge *my* answers. This is a separate pass from the Step 6 finding challenge — the target here is my context, not the assistant's findings.

Pass to the agent:
- The original question + the investigation context that surfaced it (diff, relevant files, the compiled findings)
- My answer

The agent returns a verdict per answer:
- **ACCEPT** — answer holds up; move on
- **PROBE_FURTHER** — answer has gaps, unverified claims, or optimism bias; the agent supplies a follow-up question to ask me
- **FLAG** — answer reveals a real risk (e.g., "we didn't actually check that", "no, that team wasn't told") that should become a finding

Apply the verdicts:
- ACCEPT → record the answer and proceed
- PROBE_FURTHER → ask me the follow-up question; re-run adversarial debate on the new answer (max 2 cycles, then accept or flag)
- FLAG → record as a structured finding with its own severity/risk/confidence (it gets its own verifier dispatch in Step 6 along with every other finding)

### When to skip

If no compiled finding carries `Severity: Question`, skip this step entirely.

If I've authorized auto-mode (or said "no questions, just review"), log these as a **Questions** section in the final review output (Step 5) instead of pausing. The post-answer adversarial pass is also skipped in this mode — there are no answers to challenge.

## Step 5 — Format the Review

Take the compiled findings from Step 3 + user answers + any FLAGged answers from Step 4, and structure the review as follows:

```markdown

## Review: [Brief description of what the change does]

### Verdict
**APPROVE** / **COMMENT** / **REQUEST_CHANGES** — [1 sentence: why this verdict, set by Step 7 and constrained by review relationship. COMMENT is valid only for a third-party PR.]

### Summary
[1-2 sentences demonstrating you understood the change and its purpose]

### Critical Findings

#### 1. [Category]: [Concise issue title]
**Risk:** [High | Medium | Low] · **Confidence:** [High | Medium | Low] · **Verified by:** [finding-verifier-high | finding-verifier-low]
**File:** `path/to/file.ext:LINE`
**Problem:** [What's wrong and why it matters]
**Fix:**
[Concrete code suggestion — copy-pasteable, not vague guidance]

### Non-blocking Suggestions

#### 1. [Category]: [Concise title]
**Risk:** [High | Medium | Low] · **Confidence:** [High | Medium | Low] · **Verified by:** [finding-verifier-high | finding-verifier-low]
**File:** `path/to/file.ext:LINE`
**Suggestion:** [What to improve and why]
**Example:**
[Code snippet if helpful]

### Security Deep-Dive
[Only if the compiled findings include this block — skip otherwise]

### Architecture Assessment
[Only if the compiled findings include this block — skip otherwise]

### Performance Deep-Dive
[Only if the compiled findings include this block — skip otherwise]

### Quality Deep-Dive
[Only if the compiled findings include this block — skip otherwise]

### Requirements Traceability
[Only if the compiled findings include this block — skip otherwise]

### Related-Issue Regression Risks
[Only if the compiled findings include this block — skip otherwise]

### Upcoming Project Work
[Only if an active/upcoming project issue exactly covers a duplicate non-blocking follow-up — cite the issue, status, and owned concern. This is context, not a finding.]

### Questions
- [Genuine clarifying questions that name the exact author-only information or decision needed to resolve a changed-line risk]

### Dropped Findings
- [Findings a verifier DROPped — what was considered and why it was dropped]
```

There is deliberately no "What's Good" section. Lens reviewers no longer return grounded positives, so anything written here would be the orchestrator inventing praise it did not verify. Do not add one back from your own impression of the diff.

## Step 6 — Whole-Diff Synthesis and Per-Finding Verification

Read `references/review-contract.md` and run its bounded synthesis pass before
verifier routing. Synthesis candidates enter the normal verifier route; they
never change a verdict directly.

**Every** finding is verified on its own, by its own agent, with no knowledge of the others. Nothing is batched. A shared-context batch pass is a one-way valve — it can talk a real defect down but rarely talks one up, because the cheap findings around it set the tone. Isolation is what lets an under-classified defect get promoted instead of steel-manned away.

### Route each finding to a tier

Read `references/finding-axes.md` and compute the tier mechanically from the finding's three levels:

```
finding-verifier-high  if severity == Critical
                       OR risk == High
                       OR (confidence == Low AND severity not in (Nit, Question))
finding-verifier-low   otherwise
```

Do not hand-pick a tier because a finding feels important — if it feels important, fix the levels and let the rule follow. Do not collapse everything to the high tier "to be safe"; that discards the cost control this split exists for.

### Dispatch

Send **all** dispatches — both tiers — in a single message so they run in parallel. Never sequentially. Pass each dispatch:

- `mode`, and the PR diff or local diff source of truth (plus `pr_head_sha`/`repo` and the PR-mode constraints block in PR mode)
- that finding's file paths and lines only
- the finding's claim, diff anchor, changed-line causal link, severity, risk, confidence, evidence, and proposed fix
- requirements checklist, if present and relevant to that finding
- **nothing about the other findings** — each dispatch verifies its own claim in isolation so no verdict can be biased off a sibling

High-tier returns KEEP, DOWNGRADE, DROP, REVISE, PROMOTE, or `requires clarification`. Low-tier returns the same minus PROMOTE, plus `requires escalation`. Both must cite evidence (`file:line`, or `source` + `query` + `retrieved-at`).

### Handle escalations

A low-tier `requires escalation` means the cheap pass could not honestly verify the claim. Re-dispatch that finding to `finding-verifier-high` and use the high-tier verdict. Escalations from one round can be re-dispatched together in one message.

Never resolve an escalation yourself by reasoning about it in the main window, and never treat an escalation as a DROP — an unverified finding is unverified, not disproven. If a re-dispatched finding escalates again or returns `requires clarification`, surface it as a question rather than looping (see `~/.claude/rules/loop-detection.md`).

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

Then run `/this-important strict` (unless the user asked for a broader sweep) on the remaining **low-tier findings only**. `/this-important` has no PROMOTE verdict and must not downgrade any high-tier KEEP or PROMOTE.

Before Step 7, confirm:

- every finding got its own verifier dispatch — none was batched or skipped
- no finding duplicates an existing PR thread
- every PR finding has an aggregate-diff anchor and causal link; baseline-only issues never survive
- every finding is grounded in the diff or verified source
- every surfaced finding and question passes the Actionability Gate; deep-dive and residual-risk sections do not smuggle rejected commentary back in
- every `REQUEST_CHANGES` candidate is both Critical and High risk, and truly blocks merge
- dropped findings have one-line reasons
- every escalation was re-dispatched, not silently resolved or dropped
- every `requires clarification` finding is surfaced as a question, not silently resolved either way
- the Coverage Manifest and final integrity gate in `review-contract.md` passed

## Step 7 — Verdict

The verdict is a **mechanical function of Step 6's verifier results and the
resolved review relationship**, not a fresh judgment call layered on top.

- If any finding is both post-verification `Critical` (KEPT Critical, or PROMOTEd to Critical) **and** `High` risk → **REQUEST_CHANGES**, full stop. Do not re-litigate whether it is merge-blocking — Step 6 independently verified it with cited evidence. A Critical finding at Medium or Low risk is still presented prominently, but follows the normal non-blocking verdict rules. A finding that needs clarification is never an automatic request for changes; surface it as a blocking question instead.
- Otherwise apply the mode gate:
  - **Local, branch/range, Local Issue, embedded local, self-authored PR, or unknown PR:** **APPROVE**. Keep actionable non-blocking findings and targeted questions visible, but do not turn them into `COMMENT` and do not inflate them into blockers merely to avoid approval.
  - **Third-party PR:** **APPROVE** when requirements are satisfied and every remaining finding is Low risk (including substantive actionable feedback). Use **COMMENT** when Medium/High-risk non-blocking feedback, unresolved requirements/context, stale/already-merged PR state, or explicit user instruction not to approve remains.

`COMMENT` is invalid unless the review targets an actual PR and its author login
is known to differ from the authenticated reviewer's login.

### Challenge the eligible verdict choice

`REQUEST_CHANGES` is not up for debate in this pass once Step 6 has verified a Critical, High-risk finding. For a third-party PR only, the remaining APPROVE/COMMENT choice is discretionary and receives this whole-review adversarial pass. Local, self-authored PR, and unknown-PR reviews have no COMMENT branch, so skip the pass after confirming no Critical High-risk blocker survived. Spawn `adversarial-debate` with:

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
- Every non-blocking suggestion should include example code when the alternative is not obvious.
- Raise only actionable feedback. Every finding or question must name a concrete author-controlled change, decision, or specific information request and the changed-line risk it resolves. Drop observations, preferences, generalized advice, and speculative future concerns.
- Explicitly label severity on every comment: **Critical**, **Suggestion (non-blocking)**, **Question**, or **Nit**.
- Ask rather than demand when the author may have context you lack.
- Focus on substance; do not bikeshed formatting, naming, or style unless genuinely confusing.
- Cross-service boundaries deserve extra scrutiny because subtle bugs hide there.
- Tests must test what they claim; vacuous tests are worse than no tests.
- Never re-raise an issue already present in the PR conversation.
- Reserve `REQUEST_CHANGES` for verified Critical **and High-risk** merge blockers: likely production breakage, data loss/corruption/exposure, exploitable security/privacy risk, likely runtime contract break, or an omitted must-have acceptance criterion with a likely or wide-impact launch failure. Raise every other concern only when it is actionable and clearly non-blocking. In local and self-authored/unknown PR reviews, approve whenever no such blocker survives. Use `COMMENT` only on a third-party PR when Medium/High-risk non-blocking feedback or unresolved requirements/context remains.

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
| "COMMENT vs APPROVE doesn't matter much here" | It is mode-constrained. COMMENT exists only for a third-party PR; local and self-authored/unknown PR reviews approve unless a verified Critical, High-risk blocker requires changes. |

## References

- `references/finding-axes.md` - severity/risk/confidence definitions and the Step 6 verifier-tier rule. Read by this skill, every lens reviewer, and both finding verifiers.
- `references/review-contract.md` - deterministic coverage, evidence, and final-integrity requirements for every review.
- `references/general-checklist.md` - cross-cutting Critical/non-blocking categories. Read by `general-reviewer` (and promotion target cross-cutting patterns).
- `references/cross-service-contracts.md` - checklist for cross-service changes. Read by `general-reviewer`.
- `references/project-context.md` - bounded Linear project context and exact-match follow-up calibration.
- `references/learned-misses.md` - active pattern queue. Auto-promote check runs top invocation; triage block reports promotions.
- `references/promoted-misses.md` - audit archive of promoted/discarded entries, split out of `learned-misses.md` to stay under the reference word-budget cap.
- `references/learned-miss-lifecycle.md` - capture/promote subcommands and queue auto-promotion. Load for those modes and at invocation start.
- `references/team-review-patterns.md` - team-and-community review patterns distilled from multi-developer PR mining pass. Created by separate mining pass; pass into lens reviewers (or fold relevant patterns into briefs) when present.
- `gotchas.md` - known failure patterns. This skill every lens reviewer read it.

## Gotchas

Read `gotchas.md` before starting work. Every lens reviewer reads it independently before producing findings. Patterns belonging in this skill's main flow (don't auto-publish, re-review means full re-review, propagating PR Mode constraints into subagents) are enforced here; patterns belonging in the deep per-lens investigation (lazy imports, cross-service contracts, brand capitalization) are enforced inside the reviewer agents.

## Never auto-publish

Producing the final review document is the end of this skill's job. **Do not** invoke `/publish-review`, `gh pr review`, or any GitHub-mutating command on your own. Wait for explicit direction ("post it", "looks good, publish", "ship it"). The user may want to edit findings, add context, or hold the review entirely.
