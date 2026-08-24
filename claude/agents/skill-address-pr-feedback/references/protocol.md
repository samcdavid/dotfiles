# Protocol — skill-address-pr-feedback

Full private procedure for the `skill-address-pr-feedback` runner. The `address-pr-feedback` wrapper normalizes mode, owns the PR-mode approval boundary, and renders or performs any explicitly authorized outward action. Retained standalone gotchas remain at `~/.claude/skills/address-pr-feedback/gotchas.md`, or `~/.agents/skills/address-pr-feedback/gotchas.md` under Codex.

## Address PR Feedback

Systematically work through all pending review feedback on a PR. This skill is a **condensed `my-research` → `my-plan` → `my-implement` pipeline** specialized for reviewer feedback:

- **Act I — Research** (condensed `my-research`): gather every comment and turn it into a **verified, classified finding** — substantiated by code you actually read, challenged adversarially, importance-filtered.
- **Act II — Plan** (condensed `my-plan`): split confirmed fixes into **test-drivable behavioral phases** (sized one fix per phase, with RED tests and mechanical success criteria) versus **non-behavioral direct edits**.
- **Act III — Implement** (condensed `my-implement`): dispatch each behavioral phase to a fresh **`implementation-executor`** subagent (the same agent `my-implement` uses), dispatch each non-behavioral edit to `quick-implement-agent`, re-verify each independently, and own loop detection.

Then commit locally through `Skill(commit)`, draft responses, validate and review the combined work, repair substantive findings within a three-pass cap, and return any outward work to the wrapper as an envelope.

**You orchestrate; the executor implements the behavioral fixes.** You do not write production code or tests for a behavioral fix in the main context — you slice the work, dispatch it, and re-verify what comes back as a skeptical reviewer. The exception is non-behavioral trivia, which you apply directly because it has no honest failing test.

## Getting Started

Determine which PR to address:

- If `$ARGUMENTS` contains a PR number or URL, use that.
- Otherwise, check `gh pr status` for the current branch's PR.
- If neither works, ask the user.

Before anything else, check for a `my-workflow` ledger tied to the current branch — read `references/workflow-ledger-context.md` and run its detection now, in both PR mode and local mode. When one exists, its spec, plan, decisions, and Finding Register feed the Requirements Traceability Baseline below and the investigation in Step 2, and Step 13 appends this run's round record plus resolved/deferred dispositions back to it. When none exists, this adds nothing — proceed as usual and skip Step 13.

---

## Act I — Research (condensed `my-research`)

The goal of this act is **verified findings**: every classification is backed by code you read, not by the reviewer's assertion or your memory.

## Step 1 — Gather All Feedback

Read `~/.claude/rules/pr-cost-control.md` first. Fetch only fields needed build feedback index.

```bash
gh pr view <number> --json number,title,body,headRefOid,baseRefName,headRefName,files,reviewRequests,reviews \
  --jq '{number,title,body,headRefOid,baseRefName,headRefName,files:[.files[] | {path,additions,deletions}],reviewRequests,reviews:[.reviews[] | {state,author:.author.login,body,submittedAt}]}'
gh pr diff <number>
```

Use the GraphQL `reviewThreads` query in `pr-cost-control.md` primary source inline comments, resolved state, outdated state. Use filtered REST fallbacks from that rule only for review bodies or issue-level comments not covered by threads.

Do not ingest raw `gh api` review/comment payloads. If filtered response misses required field, fetch that field explicitly.

Build a structured index of every comment, organized by:

- **Who** said it
- **Where** (file:line, or general PR comment)
- **What** they said
- **Comment ID** — the numeric ID from the API (needed for thread replies)
- **Thread ID** — for `review_comment` type, the GraphQL thread node ID (`thread_id` in `pr-cost-control.md`'s query) — needed to resolve the thread after replying
- **Comment type** — `review_comment` (inline on a file:line), `review_body` (top-level review submission), or `issue_comment` (general PR conversation)
- **Status** — is it resolved, pending, or part of an ongoing thread?
- **Has it already been addressed?** Check if there's a reply with a commit SHA or a "done" acknowledgment.

This index determines HOW you'll reply later:

- `review_comment` → reply in-thread using `in_reply_to` with the comment ID
- `review_body` → reply as a new issue comment quoting the relevant text
- `issue_comment` → reply as a new issue comment quoting the relevant text

Skip comments that are already resolved or addressed. Focus only on **pending, unresolved feedback**.

### Requirements Traceability Baseline

If the PR description links to a Linear ticket (e.g. `ENG-123`, `Fixes ENG-123`, Linear URL), fetch it using the Linear MCP tools. Extract the title, description, acceptance criteria, and sub-issues.

If Getting Started found a workflow ledger for this branch, pull its spec's acceptance criteria and the plan's phase breakdown in too — the spec is usually more granular than the raw ticket, and the plan shows which files/changes were meant to satisfy which criterion. Merge both sources into one map rather than keeping them separate.

Build a **requirements map**: for each acceptance criterion, which file(s) and change(s) in the current PR diff address it. You will use this map in the self-audit (Step 10) to verify that your fixes don't accidentally remove coverage for an original requirement.

## Step 2 — Investigate Every Comment

Apply `~/.claude/rules/pr-cost-control.md`: work from filtered comment payloads, retrieve compressed output only by relevant query, batch file/test reads for one investigation pass, and verify edits with `git diff` or targeted checks instead of immediate re-reads.

**Every comment requires investigation before deciding how to respond.** Do not accept feedback blindly, and do not reject it without evidence. The standard of rigor is the same regardless of whether you end up agreeing or disagreeing.

Before starting, read `references/pushback-patterns.md`. It documents the shapes that well-calibrated pushback takes across senior Elixir-ecosystem developers. The "When to push back vs. when to accept" decision table near the end is the load-bearing piece — use it to map each comment's category to a response pattern.

For each pending comment:

1. **Reproduce the concern.** Read the referenced code. Does the reviewer's claim hold? If they say there's a bug, can you construct the failing case? If they suggest an alternative, does it actually work in context? If they flag a missing edge case, trace the code path — does the value they're worried about actually reach this point?
2. **Check the codebase.** If the reviewer suggests using an existing utility or pattern, verify it exists and does what they think it does. If they suggest a refactor, check whether it would break callers. If they flag a naming issue, check how the term is used elsewhere in the domain.
3. **Check the docs.** If the feedback involves a library API, framework behavior, or Oban/Ecto pattern, verify against actual documentation — not memory.
4. **Check the workflow ledger, if one was found.** Does the comment match a resolved/deferred Finding Register key? If so, suppress re-planning unless a specific changed-code or new-evidence reopen trigger exists; preserve the prior disposition for any necessary reply. Does the comment revisit a decision the spec or plan already made deliberately? Treat that decision as settled, not as a fresh question — its recorded rationale is evidence for your response, per `references/workflow-ledger-context.md`. Does a `cross_workflow` sibling-overlap note make the comment's suggestion someone else's tracked work rather than this PR's?
5. **Form a judgment with evidence.** You now know whether the reviewer is right, partially right, or mistaken. Classify accordingly — and consult `references/pushback-patterns.md` to pick the response shape that fits (e.g. Pattern 3 "evidence-backed pushback" for falsifiable bot claims, Pattern 1 "out-of-scope defer" for adjacent cleanup, Pattern 4 "acknowledge-and-fix" for clear bugs).

### Deduplication Requests

When a reviewer requests deduplication (DRY refactors, "extract this repeated pattern", "this is duplicated"), count the actual occurrences before accepting:

- **≤3 occurrences** → push back. Three instances of a pattern is not a strong enough signal to justify extraction at review time. Classify as **Disagree / Push Back** (see below).
- **>3 occurrences** → treat as a Confirmed Fix or Partially Correct item and proceed.

The push-back response must:
1. Acknowledge the reviewer's DRY instinct.
2. State the actual count: "I count N occurrences of this pattern."
3. Explain the threshold: "At N occurrences, introducing an abstraction adds indirection without enough payoff — the bar for extraction is more than 3."
4. Offer to revisit: "Happy to extract it if this pattern spreads further."

### Classification

After investigation, classify each comment:

#### Confirmed Fix

Investigation confirms the reviewer is correct. You have evidence (the code path, the failing case, the doc reference) that the change should be made.

#### Question Requiring Response

The reviewer asked about intent or design. No code change needed — but your response should demonstrate you investigated, not just defended.

#### Valid Deferral

Investigation confirms the feedback is correct, but the fix is out of scope — too large, requires coordination, or is a separate concern. You have a concrete reason for deferring AND a follow-up plan. If the follow-up plan is a ticket, it is not valid evidence until you've fetched it and confirmed both that it exists and that its actual description covers this specific gap — a ticket number alone is not a plan. A deferral pointing at a nonexistent ticket, or one that's topically adjacent but doesn't actually cover the gap, is not a Valid Deferral; reclassify as Confirmed Fix.

**Low effort is never a Valid Deferral, ticket or no ticket.** If the fix is mechanical, touches one location, and requires no real design decision (roughly under 20 lines is a proxy, not the test), it does not qualify for this classification regardless of whether a ticket exists or could be opened. Reclassify as Confirmed Fix and do it in this PR. Reserve deferral for work that's genuinely large, needs coordination with another team/PR, or is a separate concern — not for "this would be quick but I'd rather track it."

#### Disagree / Push Back

Investigation shows the reviewer's suggestion would be incorrect, break something, or conflict with a constraint. You have concrete evidence (linter rule, failing test, contract, doc reference).

#### Partially Correct

The reviewer identified a real concern but their specific suggestion isn't quite right. You'll fix the underlying issue a different way. Your response should acknowledge the concern and explain your alternative approach.

#### Already Addressed

The feedback was already fixed in a subsequent commit but the reviewer wasn't notified.

### Adversarial Challenge

Before presenting your triage, spawn the **adversarial-debate** agent to challenge your classifications.

Format each classification as a finding and pass it to the agent along with:

- The original reviewer comment (full text)
- Your investigation evidence
- Your classification and planned action
- The referenced code (file paths)

The agent will challenge:

- **Confirmed Fixes**: steel-man the current code — is acceptance actually justified?
- **Push Backs**: steel-man the reviewer — could they be right and you wrong?
- **Deferrals**: is this genuinely out of scope/large/needs-coordination, or is it low-effort work being avoided by pointing at a ticket? (Under 20 lines is a proxy for low-effort, not the test — mechanical, single-location, no design decision also disqualifies a deferral regardless of line count)
- **Partially Correct**: does your alternative actually address the reviewer's concern, or sidestep it?
- **Contradictions**: accepting a pattern in one fix but pushing back on the same pattern elsewhere?

Apply the agent's verdicts — reclassify items as needed before presenting.

### Importance Filter — `/this-important`

After the adversarial challenge, run the post-investigation classifications through `/this-important` to filter for importance. Investigation tells you whether a reviewer's concern is valid; importance filtering tells you whether it's worth a fix-and-commit cycle right now versus a deferral or a brief reply.

Invoke `/this-important strict` by default. Use `moderate` if I've signaled this is a high-polish PR (release branch, external-facing API, customer-reported regression). Use `loose` only if I explicitly ask.

Pass every classified comment as a finding. Apply the returned verdicts:

- **KEEP** → stays as Confirmed Fix / Partially Correct (proceed to plan in Act II)
- **DOWNGRADE** → move from Confirmed Fix to Question Requiring Response (reply with investigation findings, no code change)
- **DEFER** → move to Valid Deferral only if it also passes the effort test above — must have a follow-up plan AND be genuinely large/out-of-scope/needs-coordination. `/this-important` judges importance, not effort; it does not know whether a fix is 3 lines or 300. If a DEFER verdict lands on a low-effort item (mechanical, single-location, no design decision), override it back to KEEP/Confirmed Fix and fix it now instead — a ticket is not a substitute for a cheap fix.
- **DROP** → only valid for items already in the Question or Push Back classifications where investigation showed no real concern; never drop a verified reviewer-flagged bug, security issue, or data-loss risk

Hard rule: never downgrade or drop a finding from a reviewer whose review was marked as blocking ("Request changes") without surfacing the change to the user explicitly. The reviewer's gate stands until they remove it; importance filtering is for your own action prioritization, not for overriding their blocking review.

Present the triage to the user **with your investigation findings**:

```

## Pending Feedback — [N] items

### Confirmed Fixes ([N])
1. [reviewer] on `file:line` — [summary]
   Investigation: [what you found that confirms this should change]
   Plan: [what you'll change]

### Partially Correct ([N])
1. [reviewer] on `file:line` — [summary]
   Investigation: [the real concern vs. the specific suggestion]
   Plan: [your alternative fix]

### Questions ([N])
1. [reviewer] — [summary]
   Investigation: [what you checked]
   Suggested response: [draft]

### Deferrals ([N])
1. [reviewer] on `file:line` — [summary]
   Investigation: [confirms it's valid]
   Reason: [why defer] | Follow-up: [ticket/plan]

### Push Back ([N])
1. [reviewer] on `file:line` — [summary]
   Evidence: [what you found that contradicts the suggestion]
```

In PR mode, return the evidence-backed triage to the wrapper and wait for its explicit execution envelope. The user may reclassify items, add context, or challenge investigation findings. **The confirmed triage is held inline, not written to a research doc.** A `Scope Decision Required` remains a separate explicit decision.

The runner may only continue with local planning, implementation, and commits when the wrapper returns confirmed scope. It never treats that envelope as authority to push, reply, resolve, or re-request review; those always return to the wrapper after validation.

---

## Act II — Plan (condensed `my-plan`)

Turn the confirmed triage into an executable fix plan. This act produces an **inline plan** (a TodoWrite list + the per-fix slices below) — no plan file is written to disk.

## Step 3 — Context for Fixes

Before planning slices, build the context the fixes need:

- **Read every changed file fully** — not just the diff hunks. You need surrounding context to avoid introducing new problems while fixing old ones.
- **Spawn a codebase-pattern-finder** if any fix involves adding new code — check whether the codebase already has a utility or pattern for what's needed. Duplicating existing functionality while addressing feedback is a common second-round review finding.
- **Spawn a docs-researcher** if any fix involves library/framework APIs — even if you investigated in Step 2, confirm the exact usage pattern before writing the slice.
- **Check for interactions between fixes** — will fixing comment A conflict with fixing comment B? If two reviewers gave contradictory feedback, flag it for the user rather than choosing one silently.

## Step 4 — Sort Fixes Into Two Tracks

For each **Confirmed Fix** and **Partially Correct** item that survived Act I, decide its track:

- **Behavioral fix (→ executor phase).** The fix changes runtime behavior, and a test could fail before the fix and pass after it: bug fixes, logic changes, new edge-case handling, corrected return shapes, validation. These get a TDD phase dispatched to `implementation-executor`.
- **Non-behavioral direct edit (→ quick-implement-agent).** The fix has no honest failing test: renames, comment/docstring wording, log-level changes, formatting, dead-code removal, doc files, pure config. You dispatch these as `direct_edit` phases to `quick-implement-agent` in Act III — they clear the same format/lint/test gate as behavioral fixes, since each phase commits and the pre-commit hook gates every commit.

When in doubt, prefer the executor track — but never invent a vacuous test just to route a fix through it. The executor **rejects a phase with no `red_tests`**; a fix that can't produce a genuine RED test belongs in the direct-edit track.

## Step 5 — Write the Phase Slices (behavioral track)

Plan each behavioral fix as **one phase = one fix**, following `my-plan`'s sizing discipline: a single bounded behavior, the smallest set of files (ideally one production file + its test), completable by a subagent that sees only this slice. PR fixes are already granular; if one "fix" bundles several behaviors, split it into ordered phases.

For each phase, define the slice the `implementation-executor` consumes (see the agent's `## Inputs`):

- `phase_name` / `phase_overview` — the reviewer's concern and what correct behavior looks like
- `red_tests` — the failing test(s) that encode the corrected behavior (paths + what each asserts)
- `green_changes` — the production change(s) that make them pass (paths + descriptions)
- `success_criteria` — **mechanical** (runnable/greppable), RED first (test exists and FAILS) then GREEN (test PASSES) plus any check
- `allowed_paths` — the file(s) this fix may touch + their tests
- `verification_commands` — how to run tests/checks in this stack (derive from the project's Makefile/justfile/CI or Step 9's command list; see `my-implement/references/verification-commands.md`)
- `architectural_constraints` — boundaries the fix must not violate (layer boundaries, dependency direction, naming) — draw from the Fix Quality Bar below
- `working_context` — cwd, stack, and **any relevant gotcha** (e.g. Elixir multi-clause grouping, concurrent-index DSL) so the executor doesn't rediscover it the hard way

Create a TodoWrite list: one todo per behavioral phase, one todo per direct-edit phase.

### Fix Quality Bar (from `my-review`)

These are the standards every fix — executor phase or direct edit — must meet. Encode the relevant ones as `architectural_constraints` in each slice, and apply them yourself when re-verifying (Step 6) and on direct edits.

**Correctness** — fix addresses the reviewer's *actual* concern; edge cases covered (for every conditional/pattern match touched, what else could the value be?); appropriate bang vs. non-bang; no lazy imports; Oban uniqueness/transaction config still correct; when adding a clause to a multi-clause Elixir function, all clauses of that name/arity stay grouped (`--warnings-as-errors` fails otherwise).
**Layer boundaries** — no API/resolver concerns leaked into contexts (or vice versa); extracted helpers live at the right layer.
**Migration safety** (if touched) — NOT NULL safe for table size; correct column types (money = `numeric(16,2)`, JSONB defaults); down migration present; concurrent index ops use the Ecto DSL (not raw SQL) with `concurrently: true` on **both** `up` and `down` under `@disable_ddl_transaction true`.
**Tests** — behavior changes have updated tests; tests at the right level (unit for branching, integration for wiring); assertions specific, not vacuous.
**Lint discipline** — no checks disabled/suppressed; no formatter violations; no new warnings.
**Existing patterns** — reuse existing utilities; if the reviewer pointed you to a function, actually use it.

State the fix plan — the behavioral phases (with what each RED test will assert) and the direct-edit list — for visibility, then proceed directly to Act III once the wrapper has supplied the confirmed execution envelope.

---

## Act III — Implement (condensed `my-implement`)

Execute the plan **one phase at a time, sequentially**. You are the orchestrator: dispatch, re-verify, own loop detection. Apply blocking feedback before non-blocking.

## Step 6 — Execute Fixes

### Behavioral phases — the orchestration loop

For each behavioral phase, in priority order (blocking before non-blocking):

1. **Assemble the slice** — pass only what this phase needs (the fields from Step 5), not the whole triage or repo. Keep the executor's context small.
2. **Dispatch ONE `implementation-executor`.** One at a time — never two in parallel; they share the working tree and fixes may touch overlapping files. Let it finish before doing anything else. (The executor commits its own validated phase, and the pre-commit hook runs format + lint + the changed tests before that commit lands — so a phase reporting a commit SHA has already cleared that gate.)
3. **Re-verify independently — you are not the implementer.** Do not take the executor's report on faith:
   - Re-run the phase's mechanical `success_criteria` yourself and read the diff.
   - Check requirements conformance against the slice: does the code satisfy `phase_overview` and the reviewer's actual concern, fully? Do the tests genuinely exercise the corrected behavior, or are they vacuous? Was anything dropped or reinterpreted? Apply the **Fix Quality Bar** above.
   - Confirm the diff stayed within `allowed_paths`.
   - All criteria pass, diff in-bounds, requirements met → phase is genuinely done. Otherwise → Loop Detection.
4. **Record and advance** — mark the phase's todo completed and move to the next. Maintain forward momentum: don't re-open finished phases, don't gold-plate, don't let an executor wander beyond its slice.

#### Loop Detection (orchestrator-owned)

The executor stops itself after one repeated failure; **you** track failures across attempts:

- **First failure** (criterion fails / executor returns `ESCALATE`): diagnose from the report + diff. If the cause is a thin brief (missing path, ambiguous criterion), tighten the slice and re-dispatch **once**.
- **Same check fails a second time** (3rd total): **STOP.** Do not re-dispatch. Surface to the user: what the fix is trying to do, what keeps failing (+ error output), what's been tried, your root-cause theory, and a suggested path forward.
- **`escalation: phase-too-big`**: split the fix into smaller ordered phases and dispatch those, or ask the user.

Escalation is efficiency, not failure. Never power through a 3-strike failure.

### Direct edits — quick-implement-agent

For each non-behavioral direct edit, dispatch it as a `direct_edit` phase to `quick-implement-agent`. Direct edits clear the same gate as behavioral phases: the agent commits, and the pre-commit hook runs format + lint + changed tests first.

Assemble the slice:
- `phase_name` / `phase_overview` — the reviewer's concern and what the fix does
- `phase_type: "direct_edit"`
- `edit_target` — file path + function name + line range (re-read the file before specifying; state may have shifted from earlier fixes in this session)
- `edit_description` — what the edit does, plus any **Fix Quality Bar** constraints relevant to this fix (encode them so the agent doesn't violate them)
- `success_criteria` — grep/lint/test checks that confirm the edit is correct and regressions are absent
- `allowed_paths` — the file(s) for this fix
- `verification_commands` — lint + relevant test command

Dispatch ONE `quick-implement-agent` per direct-edit phase. Sequential — never parallel.

Re-verify independently: read the diff, confirm the edit addressed the reviewer's underlying concern (not just the surface suggestion), confirm no ripple effects on callers or other files in the diff. Apply the **Fix Quality Bar** in your re-verify pass.

### Plan deviations

If reality differs from the plan (reported by an executor or found on re-verify): **minor** — accept the adaptation, note it, continue; **major** (a file the plan assumed doesn't exist, an API changed, the fix needs files outside every `allowed_paths`) — STOP and discuss.

## Step 7 — Local commits

Each validated phase must be committed through `Skill(commit)`, scoped to that phase's files. The executor/direct-edit agent normally invokes it itself; if a valid phase remains uncommitted, invoke `Skill(commit)` rather than `git commit`. Keep one concern per commit where practical because drafted responses reference its SHA:

```
Address review: [brief description of what changed]

- [reviewer]'s feedback on file:line — [what was fixed]
- [reviewer]'s suggestion on file:line — [what was changed]
```

After each commit, note the short SHA — you'll use it in responses.

---

## Tail — Respond, Validate, Review, Return

## Step 8 — Draft Responses

For every pending comment (fixed or not), draft a response. Every response should show that you investigated — not just acted or dismissed.

### For Confirmed Fixes

```
[Acknowledge the concern.] [Brief note on what you verified.] Fixed in [short SHA].
```

Example: "Good catch — traced the code path and `screener_type` can indeed be nil here when cloning from a template. Fixed in abc1234."

Don't just say "Fixed" — show you understood WHY it needed fixing. If you deviated from the reviewer's exact suggestion, explain your alternative and why.

### For Partially Correct Items

```
[Acknowledge the real concern.] [Explain what you found on investigation.]
[Describe your alternative fix.] Fixed in [short SHA].
```

Example: "You're right that this needs error handling, but `Req.post` returns `{:ok, resp}` / `{:error, exception}` so a case match works better than a try/rescue here. Handled both paths in def456."

### For Questions

```
[Direct answer to the question.] [Evidence or reasoning — what you checked.]
```

Be honest. If the answer is "I didn't consider that" or "good catch, investigating", say so. If you checked and the concern doesn't apply, explain what you checked and why.

### For Deferrals

```
Deferring for this PR — [concrete reason: scope, requires coordination, separate concern].
[Follow-up plan: ticket number, next sprint, or specific next step.]
```

Never defer without a follow-up plan. "I'll handle it later" without specifics is not acceptable. If you can't articulate a plan, it's not a valid deferral — just do it. Same if the fix is actually low effort (mechanical, single location, no design decision) — a ticket is not a substitute for a cheap fix; just do it. If citing a ticket number, verify it (fetched, exists, description covers this gap) before it goes in the reply — citing an unverified or non-covering ticket number in a public reply is worse than no citation, since it reads as resolved when it isn't.

### For Push Back

```
[Acknowledge the reviewer's concern.] [Concrete evidence for current approach.]
[Linter rule, doc reference, failing test, or contract constraint.]
[Offer to discuss if the reviewer still disagrees.]
```

Push back must include evidence — a linter rule citation, a failing test, a doc reference, a contract requirement. "I prefer it this way" is not push back; it's a preference, and preferences yield to reviewer feedback.

Example: "Tried consolidating these, but ruff's isort rules (I001) force the aliased import into a separate block — combining them creates a lint violation. Happy to discuss if there's a way around it I'm not seeing."

### Reply Targeting

Each drafted response must be tagged with how it will be posted:

- **Thread reply** (for `review_comment` type): Will use `gh api repos/{owner}/{repo}/pulls/{number}/comments -f body="..." -F in_reply_to={comment_id}`. This replies directly in the inline thread where the reviewer left the comment.
- **Quoted reply** (for `review_body` or `issue_comment` type): Will use `gh api repos/{owner}/{repo}/issues/{number}/comments -f body="..."`. The response body should quote the relevant portion of the original comment using `>` markdown quoting, then provide the response below the quote.

Example quoted reply for a review body comment:

```markdown
> Should we also check for launched _or_ closed?

Checked the code path — `launched?` covers both states because `closed` missions always have a `launched_at` timestamp. The only case where they diverge is draft missions, which are filtered out in the query above (line 42).
```

Present all drafted responses to the user for review before posting, showing the reply mechanism for each:

```
### Responses to Post

1. **Thread reply** to [reviewer]'s comment (ID: 12345) on `file:line`:
   > [quoted original comment]
   [your response]

2. **PR comment** quoting [reviewer]'s review body:
   > [quoted text from review]
   [your response]
```

## Step 9 — Verify

Per-phase work was already verified by the executor, by the pre-commit gate on its commit, and by your independent re-verify. During iteration, run the narrowest affected check first. This step is the **holistic gate** — run build/compile, lint/format, and the test suite once over the combined result.

Take the per-stack commands from `my-implement/references/verification-commands.md` — the same source the Step 5 slices use, so the gate and the phases can't drift apart. It also covers Python runner detection (uv vs. poetry vs. pipenv); don't assume `uv run`.

For each fix, start with the smallest affected test file or command. Save domain/package/full-suite checks for the final gate unless the narrow check cannot exercise the change.

If the project has a `Makefile`, `justfile`, or CI script, prefer those over individual commands.

When a compile/lint warning appears, first check whether its path intersects `git diff --name-only`. If it does not intersect, treat it as likely pre-existing and report it separately. Use stash-and-recompile only when path attribution is ambiguous.

If any check fails, fix the issue before proceeding. Do not leave the branch in a broken state.

## Step 10 — Review and bounded repair loop

After Step 9 passes, run `my-review` in local mode against the same base branch. If it reports Critical or substantive non-blocking findings, feed only those findings into the next repair iteration: dispatch the appropriate `implementation-executor` or `quick-implement-agent` phase, validate again, then review again. Count every `my-review` pass, including the first; cap the sequence at **3 review passes**.

Nits and clearly optional suggestions do not trigger a repair. If substantive findings remain after pass 3, stop with the surviving findings, iteration deltas, and a root-cause theory. Do not start a fourth pass. This loop is local-only: no push, reply, thread resolution, or re-request action happens here.

## Step 11 — Self-audit and external-action envelope

Work through `references/self-audit-checklist.md` — the blocking and non-blocking checks on your own fixes, the `adversarial-debate` output-validation pass over response drafts and claimed SHAs, the requirements re-check, and the meta-check for scope creep and self-contradiction. In PR mode, construct but do not execute an `external_action_requested` envelope containing only the proposed push, replies, thread resolutions, and review re-requests, their targets, order, drafts, and evidence.

## Step 12 — Summary

Present the final result:

```markdown

## PR Feedback Addressed

### Fixes Applied ([N])

| #   | Reviewer | File        | Change              | Track            | Commit |
| --- | -------- | ----------- | ------------------- | ---------------- | ------ |
| 1   | [name]   | `file:line` | [brief description] | executor /direct | [SHA]  |

### Responses Drafted ([N])

| #   | Reviewer | Type      | Summary                  |
| --- | -------- | --------- | ------------------------ |
| 1   | [name]   | Question  | [draft response summary] |
| 2   | [name]   | Deferral  | [what and why]           |
| 3   | [name]   | Push Back | [evidence summary]       |

### Requirements Traceability

[Only if a Linear ticket was linked — skip this section otherwise]
| Requirement | Pre-fix Status | Post-fix Status | Notes |
|---|---|---|---|
| [Criterion] | Covered | Covered | [unchanged / moved to X] |
| [Criterion] | Covered | Partial | [fix removed Y, needs attention] |

### Execution Notes

- Phases dispatched to executor: [N] | Re-dispatches needed: [N] (a signal for tuning future fix granularity)
- Direct edits applied: [N]

### Dropped Items

[Items where investigation or output validation failed after retries]

- [What was considered and why it was dropped]

### Verification

- Build: pass/fail
- Lint: pass/fail
- Tests: pass/fail

### External Action Requested

[PR mode only: list the exact actions, targets, drafts, order, and evidence returned for the wrapper. State that the runner performed none of them.]
```

## Step 13 — Append the Round Record and Finding Dispositions to the Ledger

Skip if Getting Started found no ledger. Otherwise this runs last — after local validation/review, or after returning the PR external-action request — so the record states what landed locally and what the wrapper still owns. Append one dated `## Feedback Round N` section and resolved/deferred Finding Register rows per `references/workflow-ledger-context.md`'s Step 4, which holds the template and the append-only write boundaries. Preserve each incoming `my-review` finding key. Report the path, round number, settled keys, and any unsettled findings in Step 12's output.

## Guidelines

- **Research, then plan, then implement.** Don't jump to editing code — investigate every comment into a verified finding (Act I), slice the confirmed fixes (Act II), then execute (Act III).
- **You orchestrate; the executor implements behavioral fixes.** Don't write a behavioral fix's tests or production code in the main context — dispatch it to `implementation-executor` and re-verify. Dispatch non-behavioral work to `quick-implement-agent` as a direct-edit phase.
- **One executor at a time.** Fixes are sequential; they share the working tree and may touch overlapping files.
- **TDD for behavioral fixes is not optional.** A behavioral phase with no honest RED test either gets a real test or moves to the direct-edit track — never a vacuous test to satisfy the executor.
- **Investigate first, act second.** Every comment — agree or disagree — deserves investigation before you decide how to respond.
- **Fix first, respond second.** Apply all code changes before drafting responses, so responses can reference specific commits.
- **Show your work.** Responses should demonstrate investigation — what you checked, what you found, why. "Fixed in abc123" without context tells the reviewer nothing.
- **One concern per commit when possible.** Makes it easy for reviewers to verify each fix maps to their feedback.
- **Never argue style.** If a reviewer prefers a different but equally valid approach, adopt it. Reserve push back for correctness and constraints.
- **Deferred is not forgotten.** Every deferral needs a concrete follow-up plan, or it's not a deferral — just do it.
- **Settled is not rehashed.** Reuse Finding Register keys across review and feedback rounds. An unchanged `resolved` or `deferred` concern is context, not another fix phase; reopen it only with specific new evidence.
- **Don't fix what wasn't flagged.** Address the feedback, nothing more — no refactoring surrounding code while you're in the file.
- **Verify before declaring done.** A PR with addressed feedback that doesn't build is worse than unaddressed feedback.
- **The wrapper owns external authority.** In PR mode, return triage first, then run only the confirmed local scope. Return outward work in an `external_action_requested` envelope; never push, publish, reply, resolve, or re-request from this runner.
- **The round outlives the session.** When a ledger exists, the run isn't done until Step 13 appended its record.

## References

- `references/pushback-patterns.md` — 12 pushback shapes distilled from a 24-developer PR mining pass. Used during Step 2 (investigate) to pick a response shape; includes a "When to push back vs. when to accept" decision table and per-person pushback fingerprints.
- `references/workflow-ledger-context.md` — checked in Getting Started, before anything else. Detects a `my-workflow` ledger tied to the current branch, folds its spec/plan/decisions into the requirements map and investigation, and holds the append-only round-record template and write boundaries for Step 13.
- `references/replies-and-publishing.md` — reply shape and the external-action envelope's exact commands and order for the wrapper.
- `references/self-audit-checklist.md` — Step 11's full checklist: blocking/non-blocking checks, output validation, requirements re-check, meta-check.
- The plan and implement acts mirror `my-plan` and `my-implement`; `my-implement/references/verification-commands.md` is the source for per-stack `verification_commands` passed into each slice.

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them. Pass any fix-relevant gotcha into the executor's slice (`working_context`) so it doesn't rediscover it the hard way.
