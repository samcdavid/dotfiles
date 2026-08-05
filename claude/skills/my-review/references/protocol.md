# Protocol — my-review

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Code Review

Perform a thorough, high-quality code review. Works on local changes (unstaged/staged/committed) or GitHub pull requests.

This skill is the **orchestrator**. It fans the work out to subagents — parallel research subagents for deep context, then specialized per-lens reviewer subagents (security, architecture, performance, QA, requirements, and a general reviewer for the rest) — and then does the parts that genuinely need the main window: triage, merging and de-duplicating the lens findings, targeted questions, the adversarial passes, the verdict, and pattern capture. The deep per-lens reasoning happens in the subagents; the judgment and synthesis happen here.

## Getting Started

Determine what to review:
- If `$ARGUMENTS` is `capture` → **Capture Mode** — queue a Learned Miss (see § "Subcommands — `capture`, `promote`"). Skip the rest of this skill.
- If `$ARGUMENTS` is `promote` → **Promote Mode** — walk the pending queue (see § "Subcommands — `capture`, `promote`"). Skip the rest of this skill.
- If `$ARGUMENTS` contains a PR number or URL → **PR Mode** (fetch the PR diff via `gh`).
- If `$ARGUMENTS` is empty or `local` → **Local Mode** (review working tree changes via `git diff`).
- If `$ARGUMENTS` contains a branch name → review diff against that branch.

Subcommand keywords (`capture`, `promote`) take precedence over branch-name interpretation.

### Read these before producing any output

- `gotchas.md` — known failure patterns for this skill.
- `references/learned-misses.md` — active pattern queue. Auto-promote any pending entries whose Evidence has crossed threshold BEFORE producing the triage block, so the triage block can report what was promoted.

## Step 1 - Gather Diff Existing Feedback

**PR Mode - read-only via `gh`, never check out branch.**

PR diff source truth. Local working tree is not PR truth: `main` may lag remote and PR branches may not exist locally.

**Hard constraints:**

- Never run `git checkout`, `git switch`, `gh pr checkout`, or fetch PRs into named local branches.
- Never read PR-changed files from local disk and treat them as PR code.
- Never compare PR against local `main` as substitute for the PR diff.
- Read PR code only via `gh pr diff <number>` and PR HEAD contents.

```bash
gh pr diff <number>
gh pr view <number>
gh pr view <number> --json files --jq '.files[].path'

sha=$(gh api repos/{owner}/{repo}/pulls/<number> --jq '.head.sha')
gh api repos/{owner}/{repo}/contents/<path>?ref=$sha --jq '.content' | base64 -d
```

Fetch existing review comments and conversation threads using `~/.claude/rules/pr-cost-control.md`: GraphQL `reviewThreads` first for inline comments/resolved/outdated state, then filtered REST fallbacks for review bodies and issue comments. Do not ingest raw `gh api` review/comment payloads.

Build `existing_comments_index`: file path, line range, substance summary, `thread_root_id`. Pass it to reviewer subagents for dedupe and use it again when merging findings.

If existing comments include your own prior review pass, treat as re-review: re-read the full diff and all comments, including issue-level threads where authors may explain what changed.

**Local Mode:**

```bash
git diff
git diff --cached
git log --oneline -5
```

Research subagents and lens reviewers read changed files fully when needed. Main context does not need to pre-read every file.

## Step 2 — Cursory Pass: Identify Review Lenses

Do a quick triage to pick which review **lenses** apply. Lenses drive which reviewer subagents you spawn in Step 3 and which deep-dive subsections appear in the final review.

### Inputs

- PR description, commit messages
- Linked Linear issue(s), referenced specs / RFCs / design docs (fetch them — don't infer)
- File-level scan of the diff: which areas changed? (backend / frontend / migrations / config / infra / tests / docs / dependency manifests)
- Existing reviewer assignments or labels on the PR

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

If the change has no obvious lens fit, default to **Backend + Security + QA**.

### Requirements checklist (if a ticket is linked)

If the PR description links to a Linear ticket (e.g. `ENG-123`, `Fixes ENG-123`, Linear URL), fetch it via the Linear MCP and build a `requirements_checklist`: title, description, acceptance criteria, sub-issues. Pass this to the `requirements-reviewer` (and activate the PM lens).

If a caller supplies a **spec or requirements document** directly (e.g. `my-workflow` passes the stage-2 spec path, or `$ARGUMENTS` names a spec/PRD), read it and build the `requirements_checklist` from its acceptance criteria the same way — a spec is an equally valid requirements source, and takes precedence when both a spec and a ticket are present. Activate the PM lens whenever any requirements source exists.

### Tracer triggers

Set `tracer_triggers.neighbor_commits_heuristic = true` if any of the diff's changed files appear in commits whose messages reference a closed Linear issue from `git log --since=60.days --name-only --pretty=format:'%H %s'`. This is the only signal that needs main-context git access — the others (PM lens active, ticket linked, requirements-audit escalated) are already known from triage.

### Plan-file lookup

Check `~/.claude/thoughts/shared/plans/` for a plan file matching the linked Linear ticket (filename or `feature:` frontmatter). If found, read the plan's surfaces (Phase sections, "Changes Required" lists, "What We're NOT Doing") and hold them as `plan_surfaces` — you'll pass them to `requirements-tracer` if it runs in Step 3.

### Triage output

Produce a short triage block and show it to me before going deep:

```
### Review Triage
- **Intent:** <1–2 sentences in your words — what this change does and why>
- **Lenses identified:**
  - <Lens> — <one-line rationale grounded in the diff>
  - <Lens> — <one-line rationale grounded in the diff>
- **Requirements checklist:** built from <ticket ID> | none linked
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

## Step 3 — Fan out, then compile

You orchestrate in two waves: research first (shared context), then specialized per-lens reviewers (parallel), then you merge everything. The deep reasoning lives in the subagents; the synthesis lives here.

### PR Mode — Hard Constraints, propagated to every subagent

Subagents will silently read on-disk files unless told not to. In PR mode you MUST paste this block verbatim into **every** subagent prompt (research and lens reviewers alike):

```
PR Mode Hard Constraints. The PR diff is the source of truth; the local working tree is NOT (main often lags remote, and the PR branch may not exist locally).
- NEVER run git checkout/switch, gh pr checkout, or git fetch origin pull/N/head:<name> — nothing that changes the working tree or creates a local branch ref.
- NEVER read PR-changed files from disk (Read/cat/grep) and treat the result as the PR's code — that reads main, not the PR.
- NEVER compare the PR against local main as a substitute for the diff.
- Read PR code ONLY via: the supplied diff_text, and `gh api repos/{repo}/contents/{path}?ref={pr_head_sha}` for full file contents at PR HEAD.
```

### Wave 1 — Research subagents (parallel, one message)

Spawn these so the lens reviewers get shared deep context instead of each re-deriving it:

- **codebase-analyzer** — deep-read the changed files AND their callers/consumers; map call chains, data flow, dependencies.
- **codebase-pattern-finder** — find how similar changes were made elsewhere; specifically whether a utility/function/module already does what new code adds (duplication is a common finding).
- **docs-researcher** — for new dependencies, or APIs/framework patterns used in ways you're not 100% sure are correct (version-specific behavior). Don't review library usage without checking the actual docs.
- **requirements-tracer** — spawn only if any `tracer_triggers` flag is true. Pass `mode: review`, `scope: wide`, the primary Linear issue ID (if any), the PR number, and `plan_surfaces` if present (it diffs predicted-vs-actual and only re-runs related-issue discovery if they differ meaningfully).

Collect their outputs into a **compact `research_notes` summary** — the load-bearing facts (call chains, duplication hits, doc gaps), not raw dumps. This is what you hand to the lens reviewers.

### Wave 2 — Lens reviewer subagents (parallel, one message)

For each active lens from Step 2, spawn its reviewer. Send them all in a single message so they run concurrently. Pass each the bundle: `mode`, `pr_head_sha`, `repo`, `diff_text`, `changed_files`, `research_notes`, `author_calibration`, `existing_comments_index`, the PR-mode constraints block, plus any lens-specific extras.

| Active lens(es) | Reviewer agent | Extra input |
|---|---|---|
| Security | `security-reviewer` | — |
| Architecture | `arch-reviewer` | — |
| Performance | `perf-reviewer` | — |
| QA | `quality-reviewer` | — |
| PM | `requirements-reviewer` | `requirements_checklist` |
| Backend, Frontend, Full-stack, Ops, Migration, Dependency | `general-reviewer` | `assigned_lenses` (the subset that fired) |

Spawn a reviewer only for lenses that actually fired in triage. Always include `general-reviewer` if any non-specialized lens is active (it also carries the cross-service-contract checks). Each reviewer reads its source-of-truth skill, applies the checklist, dedupes against `existing_comments_index`, and returns a findings fragment.

### Wave 3 — Compile

Merge the lens reviewers' fragments into one findings set:

1. **De-duplicate across reviewers.** Two lenses often flag the same line (e.g. security + general on the same input handler). Collapse to one finding, keeping the most precise framing and noting both lenses.
2. **Re-check dedupe against `existing_comments_index`** — a reviewer may have missed a thread; drop or `add_to_thread` anything already raised.
3. **Assemble** Critical Findings, Non-blocking Suggestions, Targeted Questions, What's Good, the lens deep-dive subsections each reviewer returned (Security Deep-Dive, Architecture Assessment, Performance Deep-Dive, Quality Deep-Dive, Requirements Traceability), and — if the tracer ran — Related-Issue Regression Risks.
4. **Sanity-check coverage**: every active lens produced a fragment. If a reviewer returned an `## Error` (e.g. missing `requirements_checklist`) or came back empty for a lens that clearly applies, re-dispatch it once with a tightened brief before proceeding. Do not silently drop a lens.

This compiled set is what Steps 4–8 operate on.

## Step 4 — Targeted Questions

If the compiled findings include a `### Targeted Questions` block, ask them. The point is to catch things where the situation depends on context only I have.

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
- FLAG → record as a structured finding (it will get its own adversarial pass in Step 6 along with every other finding)

### When to skip

If the compiled findings include no `### Targeted Questions` block, skip this step entirely.

If I've authorized auto-mode (or said "no questions, just review"), log these as a **Questions** section in the final review output (Step 5) instead of pausing. The post-answer adversarial pass is also skipped in this mode — there are no answers to challenge.

## Step 5 — Format the Review

Take the compiled findings from Step 3 + user answers + any FLAGged answers from Step 4, and structure the review as follows:

```markdown

## Review: [Brief description of what the change does]

### Verdict
**APPROVE** / **COMMENT** / **REQUEST_CHANGES** — [1 sentence: why this verdict, set by Step 7. Approve only when requirements are satisfied and remaining comments are minor or optional.]

### Summary
[1-2 sentences demonstrating you understood the change and its purpose]

### Critical Findings

#### 1. [Category]: [Concise issue title]
**File:** `path/to/file.ext:LINE`
**Problem:** [What's wrong and why it matters]
**Fix:**
[Concrete code suggestion — copy-pasteable, not vague guidance]

### Non-blocking Suggestions

#### 1. [Category]: [Concise title]
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

### Questions
- [Genuine clarifying questions — things where the author has context you don't]

### What's Good
- [Specific positive callouts — not filler, real recognition of good decisions]

### Dropped Findings
- [Findings that failed adversarial self-review — what was considered and why it was dropped]
```

## Step 6 — Adversarial Challenge on Findings

Format all Critical findings, non-blocking suggestions, questions, and nits as structured findings. Pass them to `adversarial-debate` with:

- PR diff or local diff source of truth
- referenced file paths and lines
- requirements checklist, if present
- proposed severity
- proposed verdict

The agent returns KEEP, DOWNGRADE, REVISE, or DROP with evidence.

PR mode caveat: adversarial agents can accidentally read the local working tree. If a DROP/REVISE verdict depends on "file does not exist," "identifier is fabricated," or "function cannot be found," verify against the PR diff or PR HEAD before applying it.

Apply verdicts:

- KEEP: present as-is.
- DOWNGRADE: move Critical to non-blocking/question, or suggestion to nit/drop.
- REVISE: update claim, severity, or fix.
- DROP: remove and note in Dropped Findings.

After adversarial review, run `/this-important strict` unless the user explicitly asked for a broader sweep. Do not let `/this-important` upgrade to `REQUEST_CHANGES` unless the finding meets the Critical merge-blocking bar.

Before Step 7, confirm:

- no finding duplicates an existing PR thread
- every finding is grounded in the diff or verified source
- every Critical finding truly blocks merge
- dropped findings have one-line reasons

## Step 7 — Adversarial Verdict Challenge

Choose the PR review verdict adversarially. Always run this step before publishing or recommending a GitHub review state.

### Propose Verdict

- **APPROVE** — requirements are satisfied, no Critical findings survive, and only minor nits or clearly optional suggestions remain.
- **COMMENT** — no Critical finding survives, but approval would overstate confidence: several substantive inline comments, unresolved requirements questions, insufficient context, stale/already-merged PR state, or the user explicitly asks not to approve.
- **REQUEST_CHANGES** — at least one **Critical** merge blocker: likely production breakage, data loss/corruption/exposure, exploitable security/privacy risk, likely runtime contract break, or omitted must-have acceptance criterion.

### Challenge Verdict

Spawn `adversarial-debate` with:

- proposed verdict
- final surviving findings
- severity classification for each finding
- triage context and active lenses

Ask it to challenge both directions:

- Is the verdict too soft because a Critical issue is hidden in non-blocking sections?
- Is the verdict too harsh because a finding is important but not actually merge-blocking?
- If COMMENT: why not APPROVE? Are the inline comments substantive or numerous enough, or is requirement satisfaction uncertain?
- If APPROVE: do the changes satisfy the requirements, and are remaining comments only minor or optional?
- If `REQUEST_CHANGES`, is the worst finding genuinely Critical under the merge-blocking bar?

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

## Subcommands — `capture`, `promote`

### `/my-review capture`

Direct, source-agnostic entry into the pattern queue. Use when a pattern surfaces outside the natural prompts in Step 6 and Step 8 — a bug report, a post-mortem, a Slack thread, a hunch.

Flow:
1. Ask: what pattern are we capturing? Collect Shape (one or two sentences, the *general* pattern), Trigger signals, and the source `ref`.
2. Check `references/learned-misses.md` and `references/promoted-misses.md` for an existing matching Shape. If found, append Evidence (`type: noted`, today's date, the source `ref`) to the existing entry.
3. Otherwise, draft the entry and confirm with me before writing under `learned-misses.md`'s `## Pending` with `status: pending`.

Default Evidence type is `noted` (the user is calling it out — neither a clean catch nor a clean miss).

Do **not** run any review flow in this mode. Just capture and exit.

### `/my-review promote`

Walk the pending queue one entry at a time (use the `walk-through` skill). For each entry with `status: pending` or `status: ready`:

1. Show the Shape, Trigger signals, and Evidence summary.
2. Reaffirm the Shape — is the generalization right, too narrow, or too broad? Offer to rewrite.
3. Confirm the **target file**:
   - Lens reference (e.g., `references/cross-service-contracts.md`) for a positive check ("review should affirmatively check for X").
   - `references/general-checklist.md` for a general-review category addition.
   - The relevant lens skill's `SKILL.md` (e.g. `~/.claude/skills/security-audit/SKILL.md`) when the pattern belongs to a specific lens.
   - `gotchas.md` for a failure-mode lesson ("skill itself does the wrong thing").
4. Confirm the exact wording — show what will be written, let me edit.
5. On approval: write to target file under the appropriate section, mark entry `status: promoted (<today's date>)`, move entry to `promoted-misses.md`'s `## Promoted` section.
6. On reject: mark `status: discarded (<today's date>, <one-line reason>)`, move to `promoted-misses.md`'s `## Discarded` section.

Do **not** run any review flow in this mode.

## Queue lifecycle and auto-promotion

The active queue at `references/learned-misses.md` (`## Pending`) is the single source of truth for patterns the skill is still learning; `references/promoted-misses.md` is the audit archive for entries that graduated or were discarded. Lifecycle:

1. **Capture** — entry appended to `learned-misses.md`'s `## Pending` with `status: pending`. Shape is the key; matching new captures against existing Shapes (check both files) appends Evidence rather than creating duplicates.
2. **Accumulate** — Evidence accrues across reviews. Both `type: caught` and `type: missed` (and `type: noted` from `capture` mode) count toward the threshold.
3. **Auto-promote** — when `len(evidence) >= 3`:
   - Draft promotion wording (from the entry's `Proposed promotion: wording` field if set; otherwise generated from Shape + Evidence summary).
   - Pick the target file (from `Proposed promotion: target` if set; otherwise inferred — see below).
   - Write to the target file under the appropriate section.
   - Mark entry `status: promoted (<today's date>)` and move it from `learned-misses.md` to `promoted-misses.md`'s `## Promoted`. Entry is preserved for audit.
4. **Surface** — at the next `/my-review` invocation, Step 2's triage block reports the auto-promotion.

### When does the auto-promote check run?

At the top of every `/my-review` invocation (after mode detection, before Step 1). Scan `## Pending` for entries whose Evidence length has crossed threshold; auto-promote them before producing the triage block.

### Target inference (when `Proposed promotion: target` is absent)

- Shape describes "review should affirmatively check for X" in a lens-specific way → that lens's skill `SKILL.md` (e.g. `~/.claude/skills/security-audit/SKILL.md`).
- Shape describes a cross-cutting review category → `references/general-checklist.md` under the appropriate section.
- Shape describes a cross-service pattern → `references/cross-service-contracts.md`.
- Shape describes "skill itself does the wrong thing" → `gotchas.md`, using the existing **Category / Context / Wrong / Right / Why / Source** structure.
- Ambiguous → transition to `status: ready` (not auto-promoted) and surface loudly in next `/my-review` triage block for me to resolve via `/my-review promote`.

### Threshold

Currently **3**. Tune by editing this section. Lower = snappier learning, more noise; higher = more conservative.

### Manual overrides

- `/my-review promote` — promote pending entries early or discard one-offs.
- `git revert` — undo an auto-promotion entirely. The queue entry stays as `promoted`; if you don't also discard it via `/my-review promote`, additional Evidence accruing later won't re-trigger auto-promote.

## Guidelines

- Every Critical merge-blocking issue must include a concrete fix, ideally replacement code.
- Every non-blocking suggestion should include example code when the alternative is not obvious.
- Explicitly label severity on every comment: **Critical**, **Suggestion (non-blocking)**, **Question**, or **Nit**.
- Ask rather than demand when the author may have context you lack.
- Focus on substance; do not bikeshed formatting, naming, or style unless genuinely confusing.
- Cross-service boundaries deserve extra scrutiny because subtle bugs hide there.
- Tests must test what they claim; vacuous tests are worse than no tests.
- Never re-raise an issue already present in the PR conversation.
- Reserve `REQUEST_CHANGES` for Critical merge blockers: likely production breakage, data loss/corruption/exposure, exploitable security/privacy risk, likely runtime contract break, or omitted must-have acceptance criteria. Non-Critical findings can be raised as comments, questions, suggestions, or nits; use `COMMENT` rather than `APPROVE` when there are several substantive inline comments or unresolved requirements concerns.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The tests pass, so it's fine" | Green tests are necessary, not sufficient — they don't catch architecture, security, or requirements gaps. Read the diff itself. |
| "It's a small PR, a light pass is enough" | Diff size doesn't predict risk. A five-line change to auth or a migration deserves the same scrutiny as a five-hundred-line refactor. |
| "This finding is annoying but not really Critical" | Match severity to `review-finding-format.md`'s bar, not to how strongly it feels in the moment. If it doesn't meet a Critical criterion, it's non-blocking — say so plainly instead of inflating it to force a fix. |
| "The author clearly knows what they're doing" | Author competence isn't evidence the diff is correct. Review the code in front of you, not your prior of the author. |
| "I already found a few issues, that's enough" | Stopping early because a quota feels met leaves real findings on the table — finish the lens sweep before triaging. |
| "The PR conversation probably already covers this" | Confirm it actually does by checking `existing_comments_index` — don't silently drop a finding on a hunch. |
| "COMMENT vs APPROVE doesn't matter much here" | It's the signal the author acts on. Reserve APPROVE for when requirements are satisfied and no Critical finding survives — don't let convenience nudge it up a level. |

## References

- `references/general-checklist.md` - cross-cutting Critical/non-blocking categories. Read by `general-reviewer` (and promotion target cross-cutting patterns).
- `references/cross-service-contracts.md` - checklist for cross-service changes. Read by `general-reviewer`.
- `references/learned-misses.md` - active pattern queue. Auto-promote check runs top invocation; triage block reports promotions.
- `references/promoted-misses.md` - audit archive of promoted/discarded entries, split out of `learned-misses.md` to stay under the reference word-budget cap.
- `references/team-review-patterns.md` - team-and-community review patterns distilled from multi-developer PR mining pass. Created by separate mining pass; pass into lens reviewers (or fold relevant patterns into briefs) when present.
- `gotchas.md` - known failure patterns. This skill every lens reviewer read it.

## Gotchas

Read `gotchas.md` before starting work. Every lens reviewer reads it independently before producing findings. Patterns belonging in this skill's main flow (don't auto-publish, re-review means full re-review, propagating PR Mode constraints into subagents) are enforced here; patterns belonging in the deep per-lens investigation (lazy imports, cross-service contracts, brand capitalization) are enforced inside the reviewer agents.

## Never auto-publish

Producing the final review document is the end of this skill's job. **Do not** invoke `/publish-review`, `gh pr review`, or any GitHub-mutating command on your own. Wait for explicit direction ("post it", "looks good, publish", "ship it"). The user may want to edit findings, add context, or hold the review entirely.
