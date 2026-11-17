---
name: follow-up-review
description: "Closure check on a PR I already reviewed: was my feedback and everyone else's addressed properly, and did the fixes introduce a regression, security issue, or other major problem? Cheap and scoped to what changed since my last review."
effort: xhigh
---

Target: `$ARGUMENTS` (a PR number or URL; empty means the current branch's PR). PR only. If I never reviewed it, say so and point me to `/my-review`.

This is a closure check, not another review. Full re-reviews keep finding something new and drift from the ticket, so these limits are the point:
- Code unchanged since my last review is closed. Raise nothing about it unless it is a security or data-loss problem.
- Raise a new finding only if it survives `my-review/references/importance-filter.md` at `strict`. A real nit nobody raised stays unraised and unlisted.
- No `review-orchestrator`, research subagents, or lens fan-out.
- Read-only: follow the PR hard constraints in `my-review/SKILL.md` Step 1 (never check out the branch), and post nothing.

**Baseline.** Find my latest submitted review (not PENDING) as `pr-overview/SKILL.md` does: `gh api repos/{owner}/{repo}/pulls/{n}/reviews`, matching `gh api user --jq .login`, and take its `commit_id` and date. The delta is `gh api .../compare/{commit_id}...{head}`, keeping only files still in the PR diff. If its status isn't `ahead` (rebase or force-push), say the range is unreliable and judge each item against the code at head, listing commits by `authoredDate`. If head hasn't moved there is no delta, and only replies can have answered anything.

**Feedback.** Collect every request or problem raised on the PR, mine and others', human and bot: review threads (the GraphQL query in `address-pr-feedback/SKILL.md` without its unresolved filter), review bodies, and issue comments. Skip praise, answered questions, and the author's own notes. Merge items with one root cause. Severity is the comment's own label (`Bug:`, `Suggestion (non-blocking):`, `Nit:`); with no label, decide at the strict bar. A thread resolved without a fix commit or reply gets checked like any other.

**Judge each item** against the code at head (`gh api .../contents/{path}?ref={sha}`), citing `file:line` and the fix SHA:
- **Addressed**: the change removes the cause the reviewer named, their way or an equivalent. A silenced symptom doesn't count: a lint suppression, a skipped or loosened test, a catch-all rescue, one call site fixed of several, or a reply with no change when a change was asked.
- **Pushback holds / fails**: check the author's reasoning against code and docs. Evidence-based pushback is accepted; a bare claim on a correctness or security item is verified, not trusted.
- **Superseded**: the code was removed or rewritten, so the comment no longer applies.
- **Partial / Not addressed**: say in one sentence what's missing.

**Delta check.** Only the delta, only these questions, with one `rg` or LSP pass for callers of any changed signature:
1. Regression: did it break behavior that worked? Read `gh pr checks`; a failing check the delta plausibly caused counts.
2. Security: authz, input handling, secrets, injection.
3. Data loss or corruption, a broken contract, an unsafe migration.
4. Ticket: fetch the Linear issue (from the PR description or branch name) and confirm the delta didn't drop an acceptance criterion. Flag drift only when the delta adds substantive behavior the ticket doesn't ask for.

Say what you checked even when clean, so "clean" means looked.

**Verdict.** APPROVE: every blocking item is Addressed, Superseded, or its pushback holds, and the delta check is clean; open non-blocking items don't hold it. COMMENT: only non-blocking items are open, or something couldn't be verified. REQUEST_CHANGES: a blocking item is open, or the delta introduced a blocker. For REQUEST_CHANGES only, run `adversarial-debate` once on the blockers, and check any "doesn't exist" DROP against the diff (it reads the working tree, per `my-review/gotchas.md`).

**Output.** The verdict in one sentence, then a table (#, from, where, ask, status, evidence), then the delta check (one line per question), then "Still open": each blocker and what it needs. Draft one short comment per open item and a short review body, and list my own threads that are now addressed so I can resolve them. Post only when I say so, following `my-review/references/publishing.md`.
