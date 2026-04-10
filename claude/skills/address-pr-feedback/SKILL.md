---
name: address-pr-feedback
description: Systematically address all pending PR review feedback. Reads comments, triages by actionability, applies fixes with commit references, drafts responses for questions and deferrals, and verifies the build passes before finishing. Manual invocation only.
disable-model-invocation: true
---

# Address PR Feedback

Systematically work through all pending review feedback on a PR. Apply fixes, respond to questions, and flag items that need discussion — then verify the result.

## Getting Started

Determine which PR to address:
- If `$ARGUMENTS` contains a PR number or URL, use that.
- Otherwise, check `gh pr status` for the current branch's PR.
- If neither works, ask the user.

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

Build a **requirements map**: for each acceptance criterion, which file(s) and change(s) in the current PR diff address it. You will use this map in Step 7 to verify that your fixes don't accidentally remove coverage for an original requirement.

## Step 2 — Investigate Every Comment

**Every comment requires investigation before deciding how to respond.** Do not accept feedback blindly, and do not reject it without evidence. The standard of rigor is the same regardless of whether you end up agreeing or disagreeing.

For each pending comment:

1. **Reproduce the concern.** Read the referenced code. Does the reviewer's claim hold? If they say there's a bug, can you construct the failing case? If they suggest an alternative, does it actually work in context? If they flag a missing edge case, trace the code path — does the value they're worried about actually reach this point?
2. **Check the codebase.** If the reviewer suggests using an existing utility or pattern, verify it exists and does what they think it does. If they suggest a refactor, check whether it would break callers. If they flag a naming issue, check how the term is used elsewhere in the domain.
3. **Check the docs.** If the feedback involves a library API, framework behavior, or Oban/Ecto pattern, verify against actual documentation — not memory.
4. **Form a judgment with evidence.** You now know whether the reviewer is right, partially right, or mistaken. Classify accordingly.

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

Get user confirmation before proceeding. The user may reclassify items, add context, or challenge your investigation findings.

## Step 3 — Research Before Fixing

Step 2 investigated each comment individually. Now build broader context for the fixes you're about to make:

- **Read every changed file fully** — not just the diff hunks. You need surrounding context to avoid introducing new problems while fixing old ones.
- **Spawn a codebase-pattern-finder** if any fix involves adding new code — check whether the codebase already has a utility or pattern for what's needed. Duplicating existing functionality while addressing feedback is a common second-round review finding.
- **Spawn a docs-researcher** if any fix involves library/framework APIs — even if you investigated in Step 2, confirm the exact usage pattern before writing code.
- **Check for interactions between fixes** — will fixing comment A conflict with fixing comment B? If two reviewers gave contradictory feedback, flag it for the user rather than choosing one silently.

## Step 4 — Apply Fixes

For each confirmed fix and partially-correct item, in priority order (blocking before non-blocking):

1. **Re-read the file and surrounding context** at the referenced line — state may have changed since Step 2 if you've already applied other fixes.
2. **Address the underlying concern, not just the surface suggestion.** If the reviewer said "use `Enum.map` here" but the real issue is an N+1 query, fix the N+1 — don't just swap the enumeration function.
3. **Apply the fix.** If the reviewer provided specific code, verify it's correct in context before using it. If it's a "partially correct" item, implement your alternative approach from the triage.
4. **Check for ripple effects** — does this fix require changes elsewhere? (callers, tests, types, other files in the diff)
5. **Run the fix through the my-review checklist.** Before committing, evaluate your change against the same categories reviewers will use on re-review. The point of addressing feedback is not to create new findings.

### Fix Quality Checks (from my-review)

Before committing each fix, verify against the review categories that reviewers will check on re-review:

**Correctness**
- [ ] The fix addresses the reviewer's actual concern (re-read their comment, then re-read your fix)
- [ ] Edge cases: for every conditional or pattern match you touched, what else could this value be?
- [ ] Bang vs. non-bang: appropriate for the error context?
- [ ] No lazy imports introduced (all imports at module level)
- [ ] If Oban jobs are involved: uniqueness config still correct? Jobs inside transactions?

**Layer Boundaries**
- [ ] No API/resolver concerns leaked into contexts (or vice versa) as part of the fix
- [ ] If you extracted a helper, it lives at the right layer

**Migration Safety** (if the fix touches a migration)
- [ ] NOT NULL constraints safe on the table size?
- [ ] Column types correct (money = `numeric(16,2)`, JSONB has defaults)?
- [ ] Down migration present and safe?

**Tests**
- [ ] If you changed behavior, tests are updated
- [ ] New tests are at the right level — unit for branching, integration for wiring only
- [ ] Assertions are specific, not vacuous

**Lint Discipline**
- [ ] No lint checks disabled or suppressed
- [ ] No formatter violations
- [ ] No new warnings

**Existing Patterns**
- [ ] New code reuses existing patterns — no duplicate utilities introduced
- [ ] If the reviewer pointed you to an existing function, you're actually using it (not reimplementing it)

### Commit Strategy

Group related fixes into logical commits. Each commit message should reference the feedback:
```
Address review: [brief description of what changed]

- [reviewer]'s feedback on file:line — [what was fixed]
- [reviewer]'s suggestion on file:line — [what was changed]
```

After each commit, note the short SHA — you'll use it in responses.

## Step 5 — Draft Responses

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
- **Quoted reply** (for `review_body` or `issue_comment` type): Will use `gh api repos/{owner}/{repo}/issues/{number}/comments -f body="..."`. The response body should quote the relevant portion of the original comment using `> ` markdown quoting, then provide the response below the quote.

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

## Step 6 — Verify

After all fixes are applied, run the full verification suite:

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

## Step 7 — Self-Audit Against my-review

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

## Step 8 — Summary

Present the final result:

```markdown
## PR Feedback Addressed

### Fixes Applied ([N])
| # | Reviewer | File | Change | Commit |
|---|---------|------|--------|--------|
| 1 | [name] | `file:line` | [brief description] | [SHA] |

### Responses Drafted ([N])
| # | Reviewer | Type | Summary |
|---|---------|------|---------|
| 1 | [name] | Question | [draft response summary] |
| 2 | [name] | Deferral | [what and why] |
| 3 | [name] | Push Back | [evidence summary] |

### Requirements Traceability
[Only if a Linear ticket was linked — skip this section otherwise]
| Requirement | Pre-fix Status | Post-fix Status | Notes |
|---|---|---|---|
| [Criterion] | Covered | Covered | [unchanged / moved to X] |
| [Criterion] | Covered | Partial | [fix removed Y, needs attention] |

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

## Step 9 — Publish Responses

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

- **Investigate first, act second.** Every comment — whether you agree or disagree — deserves investigation before you decide how to respond. Acceptance without understanding is as bad as rejection without evidence.
- **Fix first, respond second.** Apply all code changes before drafting responses. This way responses can reference specific commits.
- **Show your work.** Responses should demonstrate you investigated — what you checked, what you found, why you're taking the action you're taking. "Fixed in abc123" without context tells the reviewer nothing about whether you understood the concern.
- **One concern per commit when possible.** This makes it easy for reviewers to verify each fix maps to their feedback.
- **Never argue style.** If a reviewer prefers a different but equally valid approach, adopt it. Reserve push back for correctness and constraints.
- **Deferred is not forgotten.** Every deferral must have a concrete follow-up plan (ticket, next PR, specific timeline). If you can't articulate the plan, it's not a valid deferral — just do it.
- **Don't fix what wasn't flagged.** Resist the urge to refactor surrounding code while you're in the file. Address the feedback, nothing more.
- **Verify against the review checklist.** Your fixes will be re-reviewed. Run them through the same `/my-review` categories the reviewers use. Creating new findings while addressing old ones wastes everyone's time.
- **Verify before declaring done.** A PR with addressed feedback that doesn't build is worse than unaddressed feedback.

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
