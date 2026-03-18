---
name: my-review
description: Rigorous code review modeled on OSS standards. Reviews local changes or GitHub PRs for correctness, cross-service contracts, idempotency, test fidelity, and performance. De-duplicates against existing review comments. Researches the codebase to verify findings.
disable-model-invocation: true
---

# Code Review

Perform a thorough, high-quality code review. Works on local changes (unstaged/staged/committed) or GitHub pull requests.

## Getting Started

Determine what to review:
- If `$ARGUMENTS` contains a PR number or URL → **PR Mode** (fetch the PR diff via `gh`)
- If `$ARGUMENTS` is empty or `local` → **Local Mode** (review working tree changes via `git diff`)
- If `$ARGUMENTS` contains a branch name → review diff against that branch

## Step 1 — Gather the Diff and Existing Feedback

**PR Mode:**
```bash
gh pr diff <number>
gh pr view <number>
gh pr view <number> --json files --jq '.files[].path'
```

Also fetch ALL existing review comments and conversation threads:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate
gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate
```

Build an index of every issue already raised — file path, line range, and substance of the comment. You will use this to DE-DUPLICATE your review. Do not re-raise anything that has already been flagged, discussed, or resolved in an existing thread.

**Local Mode:**
```bash
git diff                    # unstaged
git diff --cached           # staged
git log --oneline -5        # recent commits for context
```

Read EVERY changed file fully — not just the diff hunks. You need surrounding context to review properly.

## Step 2 — Understand Intent

Before reviewing code, understand WHAT the change is trying to accomplish:
- PR description, commit messages, or linked issues
- Ask the user if intent is unclear — don't guess

State your understanding of the intent back to the user before proceeding:
> "Here's what I understand this change does and why — is this correct?"

This catches misunderstandings before they become incorrect review comments.

## Step 3 — Research the Codebase

Spawn parallel agents to build a grounded understanding of the code being changed:
- **codebase-analyzer**: Deep-read the changed files AND their callers/consumers. Understand how the changed code fits into the larger system — call chains, data flow, dependencies.
- **codebase-pattern-finder**: Find how similar changes were made elsewhere in the codebase. Identify conventions that this change should follow.

This step ensures your review is based on ACTUAL CODE, not assumptions. Do not skip it.

## Step 4 — Research Dependencies

Spawn a **docs-researcher** agent for any:
- New dependencies added
- APIs or library functions used in ways you're not 100% certain are correct
- Framework patterns that might have version-specific behavior

Do NOT review library usage without checking the actual docs. Incorrect API usage that "looks right" is a common source of bugs.

## Step 5 — Systematic Review

Review the changes against these categories, ordered by priority.

**Before raising any issue, check it against the existing comments index from Step 1. If the issue has already been raised, skip it entirely.** If an existing comment is incomplete or misses a nuance, you may ADD to it but not repeat it.

### Blocking Issues (must fix before merge)

**Correctness / Bugs**
- Logic errors, off-by-one, nil/null handling, race conditions
- Database consistency — reads from correct replica? Writes idempotent?
- Backward compatibility — can persisted state, queued jobs, or cached data from before this change cause failures after deploy?
- Cross-service contracts — do serialization formats, field names, nullable/required declarations, and type coercions align across service boundaries?

**Blast Radius**
- Does the change scope match the stated intent? Removing a guard or feature flag should not silently broaden behavior beyond what's intended.
- Are there callers or consumers of changed interfaces that aren't updated?

**Idempotency & Resilience**
- Can retries cause duplicates? (jobs, webhooks, API calls)
- Is error handling appropriate? (retry vs. fail-fast vs. dead-letter)
- Signal handling in containers (SIGTERM propagation)

**Security**
- Input validation at system boundaries
- Auth/authz checks present and correct
- No secrets in code, no SQL injection, no XSS vectors

**Test Fidelity**
- Do tests actually test what they claim? (not vacuously passing)
- Are assertions checking the right values/keys?
- Is randomness in tests masking deterministic failures?
- Coverage for the critical path — not necessarily 100%, but the important paths

### Non-blocking Suggestions (improvements, not blockers)

**Performance**
- Primary vs. follower repo for read-only queries
- N+1 queries, missing indexes, unbounded result sets
- Unnecessary computation, missing caching opportunities

**Code Cleanliness**
- Dead code, unused imports, orphaned fields
- Import organization
- Design system consistency (tokens vs. raw values)

**Clarity for Future Readers**
- Comments explaining "why not" for non-obvious decisions
- Guards scoped to known types rather than catch-all else clauses
- Naming only when genuinely ambiguous

### Security Deep-Dive (Auto-triggered)
If the diff touches ANY of the following, run `/security-audit` on the affected files before completing the review:
- Authentication or authorization logic (auth, session, token, permission, policy)
- Input parsing or validation (params, body, query, headers, deserialization)
- Database queries constructed with user input
- File upload/download handling
- External API credential usage
- CORS, CSP, or security header configuration

Incorporate the security audit findings into the review under a dedicated "Security" subsection in Blocking Issues.

## Step 6 — Format the Review

Structure the review as follows:

```markdown
## Review: [Brief description of what the change does]

### Summary
[1-2 sentences demonstrating you understood the change and its purpose]

### Blocking Issues

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

### Questions
- [Genuine clarifying questions — things where the author has context you don't]

### What's Good
- [Specific positive callouts — not filler, real recognition of good decisions]
```

## Step 7 — Verification Gate

Before presenting the review:
- [ ] Every file path and line number referenced is accurate (re-read the file to confirm)
- [ ] Every "fix" suggestion actually compiles / is syntactically valid
- [ ] No issues flagged that are actually correct code (re-read if uncertain)
- [ ] Blocking vs. non-blocking classification is accurate (don't over-block)
- [ ] Dependency docs were checked for any non-obvious API usage
- [ ] No comment duplicates anything already raised in existing review threads
- [ ] Findings are grounded in the codebase research from Step 3, not assumptions

## Guidelines

- Every blocking issue MUST include a concrete fix — never just flag a problem
- Explicitly label severity on every comment: **Bug:**, **Suggestion (non-blocking):**, **Question:**, **Nit:**
- Ask rather than demand for things where the author may have context you lack
- Focus on SUBSTANCE — don't bikeshed formatting, naming, or style unless genuinely confusing
- Cross-service boundaries deserve extra scrutiny — this is where subtle bugs hide
- Tests should test what they claim to test — vacuously passing tests are worse than no tests
- NEVER re-raise an issue that already exists in the PR conversation — add to it or skip it

## References

This skill has reference files in `references/` — consult them during review:
- `references/cross-service-contracts.md` — checklist for cross-service changes

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
