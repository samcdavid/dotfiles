# Gotchas — my-review

Known failure patterns and lessons learned. Read before starting work with this skill.

### Check all spec requirements, not just the code

- **Category:** failure-mode
- **Context:** Reviewing a PR linked to a ticket or spec
- **Wrong:** Reviewing only the code diff for correctness without checking whether all acceptance criteria are addressed
- **Right:** Fetch the linked ticket/spec and verify every acceptance criterion is addressed in the PR. Flag missing must-have launch requirements as Critical; otherwise raise a non-blocking requirements comment or question.
- **Why:** PRs that pass code review but miss spec requirements are a recurring pattern. Code can be correct and well-written but incomplete.
- **Source:** Recurring pattern in PR reviews

### Cross-service data structure contracts

- **Category:** failure-mode
- **Context:** PR changes how data is stored, extracted, or passed between services
- **Wrong:** Reviewing the change in isolation, assuming other services will adapt
- **Right:** Check that ALL consumers agree on the data structure. Look for structural divergence (nested vs flat, field-level vs parent-level, naming differences) across service boundaries.
- **Why:** Structural divergence between services is a known failure mode in polyglot monorepos — each service can pass its own tests while the integration is broken
- **Source:** Recurring pattern in polyglot monorepo PRs

### LLM prompt/tool docstring changes need eval

- **Category:** convention
- **Context:** PR changes LLM prompts, system messages, or tool docstrings
- **Wrong:** Reviewing prompt changes for readability and intent without checking for eval coverage
- **Right:** Verify there's a corresponding eval or test that validates the change doesn't regress AI behavior. Flag missing eval coverage as Critical only when the prompt/tool change can plausibly regress a launch-critical AI behavior; otherwise raise a non-blocking quality concern.
- **Why:** Prompt changes without eval coverage are high-risk — small wording changes can cause significant behavior regressions that aren't caught by traditional tests
- **Source:** Recurring pattern in AI-powered applications

### Reviews are read-only — never edit code

- **Category:** failure-mode
- **Context:** Review finds a concrete issue with an obvious fix
- **Wrong:** Editing the source file to fix the issue during the review (e.g., adding missing data formatting to a node)
- **Right:** Report the finding in the review output with a concrete code suggestion. Let the author decide whether and how to fix it. NEVER call Edit/Write tools during a review.
- **Why:** The review skill's job is to REPORT, not to ACT. Editing code during review conflates two distinct roles, bypasses the author's judgment, and can introduce changes the author didn't ask for — especially dangerous when the working tree has uncommitted changes that can't be cleanly reverted.
- **Source:** Review session where a node file was edited during review, had to manually revert

### Lazy imports are usually non-blocking unless they create runtime failure

- **Category:** convention
- **Context:** Any Python code that uses `import X` inside a function body. Applies to both new code in PRs and existing lazy imports in files being touched.
- **Wrong:** Accepting function-level imports as normal, downgrading them to "non-blocking suggestion," or writing them yourself. Common excuses: "avoids circular imports," "the file has a comment about circular imports," "nearby code does it this way." A common failure mode: new lazy imports are written AND the review only flags them as a non-blocking suggestion — when in fact the circular dependency doesn't even exist.
- **Right:** Flag lazy imports as non-blocking maintainability issues unless you can show they create a runtime failure or mask an import error that would break production; only then classify Critical. Before accepting any lazy import, verify the circular dependency actually exists by testing the module-level import. If it does exist, the fix is better module architecture — not a lazy import. The only valid exception is genuinely expensive imports (SpaCy model loading, heavy ML libraries) where startup cost measurably matters.
- **Why:** Lazy imports hide dependency relationships, create per-call overhead, bypass import-time error detection, and paper over architecture problems that get worse over time. They are NEVER an acceptable workaround for circular dependencies.
- **Source:** Recurring pattern — most recently, lazy imports were both written and reviewed without being flagged as blocking. The assumed circular import turned out not to exist at all.

### Functions defined inside functions are a code smell — flag them

- **Category:** convention
- **Context:** Any Python code that defines a function inside another function (excluding decorators and factory patterns)
- **Wrong:** Accepting nested function definitions in business logic as normal. Writing closures when a module-level function would work.
- **Right:** Flag nested function definitions as a non-blocking suggestion. Functions should be first-class citizens declared at module scope. Exceptions: decorator implementations, factory functions that genuinely need closure state, and pytest fixtures.
- **Why:** Nested functions are harder to read, harder to test independently, and harder to discover in the codebase. They obscure code organization and make it difficult to understand the module's public surface.
- **Source:** Recurring pattern in Python codebases

### Local mode reviews the whole branch, not the last commit

- **Category:** failure-mode
- **Context:** Local Mode (`/my-review` with no arguments, `local`, or a base branch name), including the `my-workflow` fix loop.
- **Wrong:** Building the scope from `git diff` + `git diff --cached` + `git log --oneline -5`. Once the branch's work is committed, both diffs are empty, and the natural fallback is `git show HEAD` / `git diff HEAD~1` — so a 9-commit branch gets reviewed as its last commit. Equally wrong: taking the merge base against a stale local `main` when `origin/main` exists.
- **Right:** Resolve the base branch, take the merge base, and diff from there: `fork=$(git merge-base origin/<base> HEAD); git diff "$fork"`. That single range covers every commit added on the branch plus staged and unstaged changes. Report the resolved base ref, commit count, and file count in the triage block, and pass `base_ref`/`fork` to the lens reviewers so nobody re-derives a narrower scope. If the range is empty, say there is nothing to review rather than substituting a narrower one.
- **Why:** Reviewing one commit out of many silently drops most of the change — and it fails quietly, since the review still produces confident findings about the slice it saw. Earlier commits on the branch are exactly where cross-commit inconsistencies live (a helper introduced in commit 2 and misused in commit 7 is invisible from either commit alone).
- **Source:** 2026-08-06 — user reported local review looking only at the last commit. `my-workflow` already computed the correct `"$base"...HEAD` scope and passed it in; standalone `my-review` had no equivalent recipe, so any direct invocation fell back to the working tree.

### Never check out the PR branch — review is read-only via `gh`

- **Category:** failure-mode
- **Context:** Any PR review — `my-review` itself and every subagent it spawns (research subagents codebase-analyzer / codebase-pattern-finder / docs-researcher, the per-lens reviewer agents, the per-finding verifiers `finding-verifier-high` / `finding-verifier-low`, and adversarial-debate). **Especially the verifiers and adversarial-debate**, which historically have been the leakage path that creates stale `pr-*` refs — and note that Step 6 now dispatches one verifier per finding, so a single review fans out many more of these agents than it used to.
- **Wrong:** Reaching the PR's code by changing the local working tree. Examples: `gh pr checkout <number>`, `git checkout <branch>`, `git switch <branch>`, `git fetch origin pull/N/head:pr-N` (creates a named local ref), or reading on-disk files and treating them as the PR's code. Equally wrong: falling back to "compare against local `main`" — local `main` is often days behind remote and is not authoritative.
- **Right:** The diff is the source of truth. `gh pr diff <number>` for the diff. `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` for full file contents at PR HEAD (sha from `gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha'`). If you genuinely need git-tool access (e.g. `git log`, `git show` for context only), `git fetch origin pull/N/head` (no `:branch` suffix) leaves only `FETCH_HEAD`, which is overwritten on next fetch.
- **Enforcement:** The constraint is baked into each per-lens reviewer agent (`security-reviewer`, `arch-reviewer`, `perf-reviewer`, `quality-reviewer`, `requirements-reviewer`, `general-reviewer`), into both per-finding verifiers (`finding-verifier-high`, `finding-verifier-low`), AND `~/.claude/agents/adversarial-debate.md` (each has a "PR Mode" section), so the agents refuse the destructive commands regardless of whether the calling prompt restates the constraint. `my-review` (the orchestrator) additionally MUST propagate the constraint block verbatim into every subagent prompt it spawns — research subagents and lens reviewers alike (Step 3). The skill cannot rely on prompt-level reminders alone — they have been forgotten.
- **Why:** The PR branch and the local working tree are different codebases. Checking out the PR pollutes the repo with state the user didn't ask for, leaves the working tree in a non-main state after the review, requires `--force` on rebased/stacked PRs, and accumulates stale refs. Comparing against local `main` produces wrong findings whenever `main` is behind remote — the review will flag fixes that were already merged, or miss conflicts the PR author resolved against newer code.
- **Source:** Multiple review sessions: `gh pr checkout` leaving repo on PR branch; `pr-*` local branches accumulating across review invocations; research agents reporting fields as missing when the PR diff clearly added them. **2026-05-28 session**: three stale refs (`pr-25809-readonly`, `pr-25834`, `pr-25871`) caught and deleted by the user. Root cause: the constraint was in `review-orchestrator.md` but NOT in `adversarial-debate.md`, and `gh pr checkout:*` is in the global permission allowlist so sub-agents could run it without prompting. Fix: baked the constraint into `adversarial-debate.md` directly so it can't be missed when invoked from a my-review prompt that forgot to repeat the constraint. (The `review-orchestrator` agent referenced here has since been retired; `my-review` now orchestrates the lens reviewers directly, and the PR-mode constraint lives in each per-lens reviewer agent — see **Enforcement** above.)

### Don't publish reviews until explicitly told — build iteratively across personas

- **Category:** convention
- **Context:** User requests reviews of the same PR from multiple personas (e.g., architect then backend, or backend then security)
- **Wrong:** Treating each persona pass as a standalone review and offering to publish after each one. Asking "want me to post this?" after every pass. Publishing a partial review before the user has seen all perspectives.
- **Right:** Build up findings iteratively across persona passes. Each pass adds to a combined review document. Only publish to the PR when the user explicitly says to post/publish. Between passes, present the findings and wait for the next instruction — the user may want another persona pass, want to edit the review, or want to combine and post.
- **Why:** Reviews from multiple personas are complementary — a backend finding might be dropped after the architect pass reveals it's consistent with convention, or vice versa. Publishing prematurely means the author sees incomplete or contradictory feedback. The user controls when the review is ready.
- **Source:** Multi-persona review session where the reviewer offered to post after the first persona pass, then had to combine findings from a second pass into a single coherent review

### Never auto-publish a review — always pause for explicit direction

- **Category:** failure-mode
- **Context:** Any point in a review session where findings are complete and ready to post
- **Wrong:** Finishing the review analysis and immediately calling `/publish-review` (or invoking publish logic directly) without the user saying to post it. This applies to first reviews, re-reviews, and single-persona passes alike.
- **Right:** Present findings to the user and stop. Wait for explicit direction ("post it", "looks good, publish", "ship it") before publishing. The user may want to edit findings, add context, or hold the review entirely.
- **Why:** Publishing to GitHub is a visible, hard-to-retract action on a shared system. The reviewer's job is to produce findings — the user decides when and whether to send them. Auto-publishing skips the user's approval gate entirely.
- **Source:** Re-review session where findings were complete and correct, but the review was published without the user directing it

### Re-review means full re-review — don't coast on prior approval

- **Category:** failure-mode
- **Context:** User asks to review a PR that was previously reviewed (re-review request, re-requested review on GitHub, or author says "re-requesting your review")
- **Wrong:** Assuming the diff hasn't changed, skipping the full review process, or saying "my previous approval stands" without re-reading the diff and all comments. This misses: rebase conflict resolutions that changed your code, new comments from the author requesting specific attention, or fixes that addressed (or broke) your prior feedback.
- **Right:** Treat every re-review as a fresh review. Re-read the full diff, re-read ALL comments (including issue-level comments where authors often explain what changed), and check if your prior findings are still valid or have been addressed. Look specifically for: author comments mentioning conflicts, edits to your changes, or requests for specific attention.
- **Why:** PRs evolve between reviews — rebases resolve conflicts (sometimes incorrectly), authors address feedback (sometimes introducing new issues), and new comments add context. Coasting on a prior approval can miss rebase errors (e.g., author edits reviewer's code during conflict resolution) or leave stale bug comments that should be retracted (e.g., flagged bugs were fixed but comments still open).
- **Source:** Recurring pattern in PR re-reviews — rebase conflict resolution and stale comment accumulation

### Brand/product name capitalisation in user-visible copy
- **Category:** convention
- **Context:** Reviewing templates, error messages, labels, button copy, scope descriptions, or alt text
- **Wrong:** Accepting lowercase or inconsistent capitalisation of a brand name in user-visible copy without flagging it
- **Right:** Check that every occurrence of a brand name in user-facing strings uses the correct capitalisation. Grep for existing uses in the codebase if unsure — the established form is usually visible in nearby alt text or existing copy
- **Why:** Brand names have prescribed capitalisation that differs from standard English rules. Inconsistency across strings in the same file (e.g. correct in alt text, wrong in body copy) is a common failure mode
- **Source:** Consent page template where brand name was written lowercase in body copy while alt text in the same file used the correct capitalised form

### Verifying agents read the working tree too — verify DROP verdicts against the diff

- **Category:** failure-mode
- **Context:** Running `finding-verifier-high`, `finding-verifier-low`, or adversarial-debate against review findings on a PR
- **Wrong:** Accepting a DROP or REVISE verdict when the agent's stated evidence is that a file "doesn't exist," an identifier is "fabricated," or a function "cannot be found." These agents read the local file system (current branch, usually main) — for PRs that add new files, those files don't exist locally.
- **Right:** When a verifier DROPs a finding because something allegedly doesn't exist, verify the claim directly against the PR diff before applying the verdict. If the diff shows the file or identifier is present, override the DROP and KEEP the finding. The diff is the source of truth — not `git ls-tree`, `grep`, or any tool that operates on the local working tree.
- **Why:** These agents use the same filesystem tools as research agents. They have no awareness of the PR branch context. New files added by a PR are real — they just haven't been checked out locally. An agent that reports "no such file" is reading the wrong codebase and will incorrectly conclude that valid diff-based findings were fabricated.
- **Source:** Adversarial challenge where new files clearly present in the PR diff were reported as non-existent, causing valid non-blocking findings to be dropped

### CI status is out of scope — don't dig, even when another reviewer cites red CI

- **Category:** failure-mode
- **Context:** Reviewing a PR whose checks are failing, or whose existing conversation cites CI as a blocker
- **Wrong:** Running `gh pr checks`, the commit-status API, or a CI provider's CLI (`rwx results`/`rwx logs`, CircleCI) to find out why a pipeline is red, then downloading and grepping the failing task's log. Equally wrong: adopting another reviewer's "red CI" blocker as your own finding because it looks decision-relevant to whether that blocker is still live.
- **Right:** Don't fetch check status at all. If an existing review cites red CI, `existing_comments_index` already covers it — record that the other reviewer raised it and move on, because it is their finding and not yours. If CI state genuinely looks decision-relevant to your verdict, surface it as a Targeted Question naming `ci-babysit` instead of investigating. Reviewing CI configuration the diff actually changes (a workflow file, pipeline config, build script) stays fully in scope — that is code in the diff; the boundary is on querying run status, not on reading CI config the PR touches.
- **Why:** CI reports its own findings on its own surface, and the author sees the same red check you would. Red CI is not a review finding and green CI is not evidence the diff is correct, so neither should move the verdict. The impulse is self-reinforcing: it feels diligent, and one PR where the check looks justified becomes a habit carried unprompted into the next PR. Pipeline diagnosis is also a far deeper rabbit hole than it appears — an unrelated infra flake can absorb a whole review's budget. "Must not influence the verdict" is the weaker version of this rule and is unenforceable, since a pipeline you have already read colors judgment; not looking is the cheap, checkable behavior.
- **Scope — do not generalize this:** it is a `my-review` boundary about pipeline health as an *input to a review verdict*. Verifying a CI claim somebody has already **published** is a different job, and there the check state is the very thing under test — e.g. `adversarial-debate` fact-checking a draft that asserts "that red run was a flake, the rerun was green" must look, and on 2026-08-12 doing so caught exactly that claim being false (the red belonged to a different PR and never went green). That constraint lives only in `references/pr-mode.md` and this file; `adversarial-debate` and `claude/rules/` are deliberately untouched.
- **Source:** `pr-review-loop` batch run, 2026-08-12. `gh pr checks` on PR #27959, triggered by a human `REQUEST_CHANGES` citing red CI as one of two stated blockers; the habit then carried unprompted into PR #27994, escalating to the commit-status API plus a CI-provider CLI to download and grep a failing task log. The user interrupted mid-turn once they saw the CI logs being pulled. The failure there was an unrelated dependency-download flake — genuinely useful information, but the author already had it from CI, and rediscovering it cost a deep dig.

### A low-tier escalation is unverified, not disproven

- **Category:** failure-mode
- **Context:** Step 6 per-finding verification, when `finding-verifier-low` returns `requires escalation`
- **Wrong:** Treating the escalation as a DROP ("the cheap verifier couldn't confirm it, so it's probably nothing"), or resolving it yourself by reasoning about the finding in the main window instead of re-dispatching.
- **Right:** Re-dispatch that finding to `finding-verifier-high` and use the high-tier verdict. If it escalates again or returns `requires clarification`, surface it as a question rather than looping.
- **Why:** `requires escalation` means the low tier honestly reported that verification needed depth it didn't have — that is the escalation hatch working correctly. Reading it as a negative verdict inverts its meaning and quietly discards exactly the findings the two-tier split was built to catch: the ones too costly for a cheap pass to confirm. Resolving it in the main window defeats the isolation that makes per-finding verification worth anything, since the main window has every other finding in context.
- **Source:** Introduced with the two-tier per-finding verifier split; the escalation path is the one direction where a cheap verdict can silently lose a real defect
