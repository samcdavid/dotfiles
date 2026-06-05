---
model: opus
name: address-pr-feedback
description: Systematically address all pending PR review feedback as a condensed research → plan → implement pipeline. Investigates and triages comments into verified findings, plans test-drivable fixes as small one-fix phases, dispatches each to an isolated implementation-executor (strict TDD), applies non-behavioral trivia directly, then commits with references, drafts evidence-backed responses, and verifies before finishing. Manual invocation only.
disable-model-invocation: true
---

# Address PR Feedback

Systematically work through all pending review feedback on a PR. This skill is a **condensed `my-research` → `my-plan` → `my-implement` pipeline** specialized for reviewer feedback:

- **Act I — Research** (condensed `my-research`): gather every comment and turn it into a **verified, classified finding** — substantiated by code you actually read, challenged adversarially, importance-filtered.
- **Act II — Plan** (condensed `my-plan`): split confirmed fixes into **test-drivable behavioral phases** (sized one fix per phase, with RED tests and mechanical success criteria) versus **non-behavioral direct edits**.
- **Act III — Implement** (condensed `my-implement`): dispatch each behavioral phase to a fresh **`implementation-executor`** subagent (the same agent `my-implement` uses), re-verify each independently, and own loop detection. Apply direct edits yourself.

Then commit with feedback references, draft responses, verify, and publish.

**You orchestrate; the executor implements the behavioral fixes.** You do not write production code or tests for a behavioral fix in the main context — you slice the work, dispatch it, and re-verify what comes back as a skeptical reviewer. The exception is non-behavioral trivia, which you apply directly because it has no honest failing test.

## Getting Started

Determine which PR to address:

- If `$ARGUMENTS` contains a PR number or URL, use that.
- Otherwise, check `gh pr status` for the current branch's PR.
- If neither works, ask the user.

---

# Act I — Research (condensed `my-research`)

The goal of this act is **verified findings**: every classification is backed by code you read, not by the reviewer's assertion or your memory.

## Step 1 — Gather All Feedback

Fetch everything:

```bash
gh pr view <number> --json title,body,files,reviewRequests,reviews
gh pr diff <number>
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate
gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate
```

Build a structured index of every comment, organized by:

- **Who** said it
- **Where** (file:line, or general PR comment)
- **What** they said
- **Comment ID** — the numeric ID from the API (needed for thread replies)
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

Build a **requirements map**: for each acceptance criterion, which file(s) and change(s) in the current PR diff address it. You will use this map in the self-audit (Step 10) to verify that your fixes don't accidentally remove coverage for an original requirement.

## Step 2 — Investigate Every Comment

**Every comment requires investigation before deciding how to respond.** Do not accept feedback blindly, and do not reject it without evidence. The standard of rigor is the same regardless of whether you end up agreeing or disagreeing.

Before starting, read `references/pushback-patterns.md`. It documents the shapes that well-calibrated pushback takes across senior Elixir-ecosystem developers. The "When to push back vs. when to accept" decision table near the end is the load-bearing piece — use it to map each comment's category to a response pattern.

For each pending comment:

1. **Reproduce the concern.** Read the referenced code. Does the reviewer's claim hold? If they say there's a bug, can you construct the failing case? If they suggest an alternative, does it actually work in context? If they flag a missing edge case, trace the code path — does the value they're worried about actually reach this point?
2. **Check the codebase.** If the reviewer suggests using an existing utility or pattern, verify it exists and does what they think it does. If they suggest a refactor, check whether it would break callers. If they flag a naming issue, check how the term is used elsewhere in the domain.
3. **Check the docs.** If the feedback involves a library API, framework behavior, or Oban/Ecto pattern, verify against actual documentation — not memory.
4. **Form a judgment with evidence.** You now know whether the reviewer is right, partially right, or mistaken. Classify accordingly — and consult `references/pushback-patterns.md` to pick the response shape that fits (e.g. Pattern 3 "evidence-backed pushback" for falsifiable bot claims, Pattern 1 "out-of-scope defer" for adjacent cleanup, Pattern 4 "acknowledge-and-fix" for clear bugs).

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

Investigation confirms the feedback is correct, but the fix is out of scope — too large, requires coordination, or is a separate concern. You have a concrete reason for deferring AND a follow-up plan.

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
- **Deferrals**: is this genuinely out of scope, or avoiding a hard fix? (Under 20 lines = not a deferral)
- **Partially Correct**: does your alternative actually address the reviewer's concern, or sidestep it?
- **Contradictions**: accepting a pattern in one fix but pushing back on the same pattern elsewhere?

Apply the agent's verdicts — reclassify items as needed before presenting.

### Importance Filter — `/this-important`

After the adversarial challenge, run the post-investigation classifications through `/this-important` to filter for importance. Investigation tells you whether a reviewer's concern is valid; importance filtering tells you whether it's worth a fix-and-commit cycle right now versus a deferral or a brief reply.

Invoke `/this-important strict` by default. Use `moderate` if I've signaled this is a high-polish PR (release branch, external-facing API, customer-reported regression). Use `loose` only if I explicitly ask.

Pass every classified comment as a finding. Apply the returned verdicts:

- **KEEP** → stays as Confirmed Fix / Partially Correct (proceed to plan in Act II)
- **DOWNGRADE** → move from Confirmed Fix to Question Requiring Response (reply with investigation findings, no code change)
- **DEFER** → move to Valid Deferral (must have a follow-up plan)
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

Get user confirmation before proceeding. The user may reclassify items, add context, or challenge your investigation findings. **The confirmed triage is the research output of this skill — it is held inline, not written to a research doc.**

---

# Act II — Plan (condensed `my-plan`)

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
- **Non-behavioral direct edit (→ quick-implement-agent).** The fix has no honest failing test: renames, comment/docstring wording, log-level changes, formatting, dead-code removal, doc files, pure config. You dispatch these as `direct_edit` phases to `quick-implement-agent` in Act III — they clear the same format/lint/test SubagentStop gate as behavioral fixes.

When in doubt, prefer the executor track — but never invent a vacuous test just to route a fix through it. The executor **rejects a phase with no `red_tests`**; a fix that can't produce a genuine RED test belongs in the direct-edit track.

## Step 5 — Write the Phase Slices (behavioral track)

Plan each behavioral fix as **one phase = one fix**, following `my-plan`'s sizing discipline: a single bounded behavior, the smallest set of files (ideally one production file + its test), completable by a subagent that sees only this slice. PR fixes are already granular; if one "fix" bundles several behaviors, split it into ordered phases.

For each phase, define the slice the `implementation-executor` consumes (see the agent's `## Inputs`):

- `phase_name` / `phase_overview` — the reviewer's concern and what correct behavior looks like
- `red_tests` — the failing test(s) that encode the corrected behavior (paths + what each asserts)
- `green_changes` — the production change(s) that make them pass (paths + descriptions)
- `success_criteria` — **mechanical** (runnable/greppable), RED first (test exists and FAILS) then GREEN (test PASSES) plus any check
- `allowed_paths` — the file(s) this fix may touch + their tests
- `verification_commands` — how to run tests/checks in this stack (derive from the project's Makefile/justfile/CI or Step 9's command list; see `my-implement`'s `references/verification-commands.md`)
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

Present the fix plan to the user — the behavioral phases (with what each RED test will assert) and the direct-edit list — and get a quick confirmation of the approach before executing. The triage was already approved in Act I; this confirms *how* you'll fix, not *whether*.

---

# Act III — Implement (condensed `my-implement`)

Execute the plan **one phase at a time, sequentially**. You are the orchestrator: dispatch, re-verify, own loop detection. Apply blocking feedback before non-blocking.

## Step 6 — Execute Fixes

### Behavioral phases — the orchestration loop

For each behavioral phase, in priority order (blocking before non-blocking):

1. **Assemble the slice** — pass only what this phase needs (the fields from Step 5), not the whole triage or repo. Keep the executor's context small.
2. **Dispatch ONE `implementation-executor`.** One at a time — never two in parallel; they share the working tree and fixes may touch overlapping files. Let it finish before doing anything else. (A `SubagentStop` hook independently re-runs format + lint + the changed tests on what the executor touched — so a green report has already cleared that gate.)
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

For each non-behavioral direct edit, dispatch it as a `direct_edit` phase to `quick-implement-agent`. The SubagentStop hook fires identically to behavioral phases (format + lint + changed tests) — direct edits clear the same gate.

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

## Step 7 — Commit

Unlike `my-implement` (which commits nothing — executors only produce working-tree changes), this skill **does** commit, because responses reference commit SHAs. Group related fixes into logical commits; each message references the feedback:

```
Address review: [brief description of what changed]

- [reviewer]'s feedback on file:line — [what was fixed]
- [reviewer]'s suggestion on file:line — [what was changed]
```

After each commit, note the short SHA — you'll use it in responses.

---

# Tail — Respond, Verify, Publish

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

Never defer without a follow-up plan. "I'll handle it later" without specifics is not acceptable. If you can't articulate a plan, it's not a valid deferral — just do it.

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

Per-phase work was already verified by the executor, its `SubagentStop` hook, and your independent re-verify. This step is the **holistic gate** — run the full suite once over the combined result:

### Build / Compile

- Elixir: `mix compile --warnings-as-errors`
- TypeScript: `npx tsc --noEmit`
- Python: `uv run ruff check` + `uv run ruff format --check`

### Lint / Format

- Elixir: `mix format --check-formatted` + `mix credo` (if present)
- TypeScript: `npx eslint .` + `npx prettier --check .`
- Python: `uv run ruff check` + `uv run ruff format --check`

### Tests

- Elixir: `mix test`
- TypeScript: `npm test`
- Python: `uv run pytest`

If the project has a `Makefile`, `justfile`, or CI script, prefer those over individual commands.

If any check fails, fix the issue before proceeding. Do not leave the branch in a broken state.

## Step 10 — Self-Audit Against my-review

Before presenting the final result, run your changes through the full `/my-review` checklist. The point is to catch anything that would be flagged on re-review — your fixes should not create new findings.

Read the my-review skill (`~/.claude/skills/my-review/SKILL.md`) Step 5 categories and evaluate your changes against every applicable section:

### Blocking-level checks on your fixes

- [ ] **Correctness**: No new logic errors, edge cases, or incorrect bang/non-bang usage
- [ ] **Blast radius**: No callers broken, no fallback clauses missing from new pattern matches
- [ ] **Layer boundaries**: No API concerns in contexts, no business logic in resolvers
- [ ] **Idempotency & resilience**: No unbounded loops, retries have safeguards, Oban config correct
- [ ] **Transaction design**: Oban jobs in Multi, no unnecessary `Multi.run`, bulk ops where appropriate
- [ ] **Migration safety**: NOT NULL safe, correct column types, down migration present
- [ ] **Security**: No auth token exposure, routes scoped correctly, input validated
- [ ] **Test fidelity**: Tests assert specific values, not vacuously passing
- [ ] **Test placement**: Unit tests for branching, integration tests for wiring only
- [ ] **Lint discipline**: No checks disabled, no formatter violations, no new warnings
- [ ] **Requirements**: Fixes didn't accidentally remove coverage for a requirement from the original PR

### Non-blocking checks on your fixes

- [ ] **Performance**: No N+1 introduced, no app-side filtering where SQL would work, correct index usage
- [ ] **Existing pattern reuse**: No duplicate utilities, using codebase conventions
- [ ] **Naming**: Names match domain concepts, no magic numbers introduced
- [ ] **Log levels**: Appropriate severity for any new logging
- [ ] **Forward-looking**: Fixes don't reinforce patterns known to be changing

### Output Validation

Spawn the **adversarial-debate** agent to validate your response drafts and fix claims.

Format your responses and fix summaries as findings and pass them to the agent along with:

- The committed code (post-fix state)
- The commit SHAs you're referencing
- The investigation claims you're making in responses

The agent will verify:

- File:line references are accurate (lines may have shifted from fixes)
- Quoted identifiers exist in the codebase
- Commit SHAs are real
- Code shown in responses matches actual committed code
- Investigation claims still hold (e.g., "X can be nil here" — is that still true?)

Apply verdicts — fix invalid references, weaken unverifiable claims, drop items that can't be salvaged after 2 attempts.

### Requirements Re-check

If a requirements map was built in Step 1:

- [ ] Re-map every acceptance criterion against the post-fix state of the PR. Did any of your fixes accidentally remove coverage for a requirement?
- [ ] If a fix changed the approach for a requirement (e.g. moved logic to a different layer per reviewer feedback), update the requirements map to reflect the new location.
- [ ] Flag any requirement that is now uncovered or partially covered as a result of your changes.

### Meta-check

- [ ] Every response includes evidence of investigation, not just "done"
- [ ] No fixes introduced that weren't requested (scope creep on the fix round)
- [ ] Contradictions between your fixes and your push-backs? (e.g. fixing a pattern in one place but defending it in another)
- [ ] Importance bar from `/this-important` applied consistently — fixes match the items that survived filtering; dropped/deferred items were not silently fixed anyway

## Step 11 — Summary

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

### Ready to post?

[Ask user whether to post the drafted responses to GitHub]
```

## Step 12 — Publish Responses

Only after user confirmation. Push any new commits first, then post responses.

### Push Commits

```bash
git push
```

### Post Thread Replies

For each response targeting an inline review comment (has a `comment_id`):

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  -f body="Response text" \
  -F in_reply_to={comment_id}
```

### Post PR-Level Replies

For each response targeting a review body or issue comment (no `comment_id`):

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments \
  -f body="> Quoted original text

Response text"
```

### Publish Order

1. Push commits first — so commit SHA links in responses resolve correctly
2. Thread replies next — these are the most targeted and expected
3. PR-level replies last

### Error Handling

- If a thread reply fails (e.g. comment ID no longer exists), report the error and fall back to a PR-level comment quoting the original
- If a push fails, do NOT post responses — commit SHAs in responses would be wrong
- Report each posted response as it succeeds so the user can track progress

## Guidelines

- **Research, then plan, then implement.** Don't jump to editing code — investigate every comment into a verified finding (Act I), slice the confirmed fixes (Act II), then execute (Act III).
- **You orchestrate; the executor implements behavioral fixes.** Don't write a behavioral fix's tests or production code in the main context — dispatch it to `implementation-executor` and re-verify. Only non-behavioral trivia is yours to edit directly.
- **One executor at a time.** Fixes are sequential; they share the working tree and may touch overlapping files.
- **TDD for behavioral fixes is not optional.** A behavioral phase with no honest RED test either gets a real test or moves to the direct-edit track — never a vacuous test to satisfy the executor.
- **Investigate first, act second.** Every comment — agree or disagree — deserves investigation before you decide how to respond.
- **Fix first, respond second.** Apply all code changes before drafting responses, so responses can reference specific commits.
- **Show your work.** Responses should demonstrate investigation — what you checked, what you found, why. "Fixed in abc123" without context tells the reviewer nothing.
- **One concern per commit when possible.** Makes it easy for reviewers to verify each fix maps to their feedback.
- **Never argue style.** If a reviewer prefers a different but equally valid approach, adopt it. Reserve push back for correctness and constraints.
- **Deferred is not forgotten.** Every deferral needs a concrete follow-up plan, or it's not a deferral — just do it.
- **Don't fix what wasn't flagged.** Address the feedback, nothing more — no refactoring surrounding code while you're in the file.
- **Verify before declaring done.** A PR with addressed feedback that doesn't build is worse than unaddressed feedback.

## References

- `references/pushback-patterns.md` — 12 pushback shapes distilled from a 24-developer PR mining pass. Used during Step 2 (investigate) to pick a response shape; includes a "When to push back vs. when to accept" decision table and per-person pushback fingerprints.
- The plan and implement acts mirror `my-plan` and `my-implement`; `my-implement`'s `references/verification-commands.md` is the source for per-stack `verification_commands` passed into each slice.

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them. Pass any fix-relevant gotcha into the executor's slice (`working_context`) so it doesn't rediscover it the hard way.
