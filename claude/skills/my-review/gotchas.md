# Gotchas — my-review

Known failure patterns and lessons learned. Read before starting work with this skill.

### Check all spec requirements, not just the code

- **Category:** failure-mode
- **Context:** Reviewing a PR linked to a ticket or spec
- **Wrong:** Reviewing only the code diff for correctness without checking whether all acceptance criteria are addressed
- **Right:** Fetch the linked ticket/spec and verify every acceptance criterion is addressed in the PR. Flag missing requirements as blocking issues.
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
- **Right:** Verify there's a corresponding eval or test that validates the change doesn't regress AI behavior. Flag missing eval coverage as a blocking issue.
- **Why:** Prompt changes without eval coverage are high-risk — small wording changes can cause significant behavior regressions that aren't caught by traditional tests
- **Source:** Recurring pattern in AI-powered applications

### Reviews are read-only — never edit code

- **Category:** failure-mode
- **Context:** Review finds a concrete issue with an obvious fix
- **Wrong:** Editing the source file to fix the issue during the review (e.g., adding missing data formatting to a node)
- **Right:** Report the finding in the review output with a concrete code suggestion. Let the author decide whether and how to fix it. NEVER call Edit/Write tools during a review.
- **Why:** The review skill's job is to REPORT, not to ACT. Editing code during review conflates two distinct roles, bypasses the author's judgment, and can introduce changes the author didn't ask for — especially dangerous when the working tree has uncommitted changes that can't be cleanly reverted.
- **Source:** Review session where a node file was edited during review, had to manually revert

### Lazy imports are a blocking issue — not just a code smell

- **Category:** convention
- **Context:** Any Python code that uses `import X` inside a function body. Applies to both new code in PRs and existing lazy imports in files being touched.
- **Wrong:** Accepting function-level imports as normal, downgrading them to "non-blocking suggestion," or writing them yourself. Common excuses: "avoids circular imports," "the file has a comment about circular imports," "nearby code does it this way." A common failure mode: new lazy imports are written AND the review only flags them as a non-blocking suggestion — when in fact the circular dependency doesn't even exist.
- **Right:** Flag lazy imports as a **blocking issue**. Before accepting any lazy import, verify the circular dependency actually exists by testing the module-level import. If it does exist, the fix is better module architecture — not a lazy import. The only valid exception is genuinely expensive imports (SpaCy model loading, heavy ML libraries) where startup cost measurably matters.
- **Why:** Lazy imports hide dependency relationships, create per-call overhead, bypass import-time error detection, and paper over architecture problems that get worse over time. They are NEVER an acceptable workaround for circular dependencies.
- **Source:** Recurring pattern — most recently, lazy imports were both written and reviewed without being flagged as blocking. The assumed circular import turned out not to exist at all.

### Functions defined inside functions are a code smell — flag them

- **Category:** convention
- **Context:** Any Python code that defines a function inside another function (excluding decorators and factory patterns)
- **Wrong:** Accepting nested function definitions in business logic as normal. Writing closures when a module-level function would work.
- **Right:** Flag nested function definitions as a non-blocking suggestion. Functions should be first-class citizens declared at module scope. Exceptions: decorator implementations, factory functions that genuinely need closure state, and pytest fixtures.
- **Why:** Nested functions are harder to read, harder to test independently, and harder to discover in the codebase. They obscure code organization and make it difficult to understand the module's public surface.
- **Source:** Recurring pattern in Python codebases

### Research agents read the working tree, not the PR branch — and never use `gh pr checkout`

- **Category:** failure-mode
- **Context:** Spawning codebase-analyzer or codebase-pattern-finder agents during a PR review to verify claims about changed files
- **Wrong:** Spawning research agents that read on-disk files (the current local branch, usually `main`) and treating their findings as ground truth about the PR's code. Also wrong: using `gh pr checkout <number>` to "fix" this — it leaves the repo on the PR branch after the review, and relies on local `main` being current (it may not be).
- **Right:** The diff is the source of truth. Use `gh pr diff <number>` to get the full diff and work from that. For full file contents at PR HEAD, use the GitHub API without checking out: `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` where sha comes from `gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha'`. For any agent finding about a file the PR modifies, verify the claim against the actual diff before including it in the review.
- **Why:** The PR diff and the local working tree are different codebases. Research agents have no awareness of the PR context — they read whatever is on disk. `gh pr checkout` is tempting but wrong for reviews: it leaves the repo in a non-main state, and local `main` is often behind remote, so neither the checkout nor the working tree is a reliable reference.
- **Source:** Review where `gh pr checkout` was used — correctly read PR files but left repo on PR branch; also earlier case where a codebase-analyzer reported a field was missing when the PR diff clearly added it

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

### Adversarial agent reads the working tree too — verify DROP verdicts against the diff

- **Category:** failure-mode
- **Context:** Running the adversarial-debate agent to challenge review findings on a PR
- **Wrong:** Accepting an adversarial DROP or REVISE verdict when the agent's stated evidence is that a file "doesn't exist," an identifier is "fabricated," or a function "cannot be found." The adversarial agent reads the local file system (current branch, usually main) — for PRs that add new files, those files don't exist locally.
- **Right:** When the adversarial agent DROPs a finding because something allegedly doesn't exist, verify the claim directly against the PR diff before applying the verdict. If the diff shows the file or identifier is present, override the DROP and KEEP the finding. The diff is the source of truth — not `git ls-tree`, `grep`, or any tool that operates on the local working tree.
- **Why:** The adversarial-debate agent uses the same filesystem tools as research agents. It has no awareness of the PR branch context. New files added by a PR are real — they just haven't been checked out locally. An agent that reports "no such file" is reading the wrong codebase and will incorrectly conclude that valid diff-based findings were fabricated.
- **Source:** Adversarial challenge where new files clearly present in the PR diff were reported as non-existent, causing valid non-blocking findings to be dropped

### Don't create local branch refs from PR heads — use `gh pr diff` + `gh api` instead

- **Category:** anti-pattern
- **Context:** Reading PR-only files during a review (files added by the PR that don't exist on main)
- **Wrong:** Running `git fetch origin pull/N/head:pr-N` to create a local branch ref, then using `git show pr-N:<path>` to read files. This pollutes the local repo with refs that aren't yours, requires `--force` on rebased stacked PRs, and accumulates stale `pr-*` refs over time.
- **Right:** Use `gh pr diff <number>` for the full diff. For full file contents at PR HEAD, use `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` (where sha is from `gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha'`). If you genuinely need git-tool access (e.g. `git log`, `git show` for context), use `git fetch origin pull/N/head` (no `:branch` suffix) and reference `FETCH_HEAD` — it's overwritten on next fetch, no cleanup needed.
- **Why:** Creating named local refs from PRs is a permanent side effect on the user's repo for a one-shot read. It's surprising behavior (the user didn't ask for those branches), and stacked/rebased PRs cause "non-fast-forward" errors that tempt the use of `--force` to clean up Claude's own mess. `gh pr diff` and `gh api .../contents?ref=` are the lighter-weight alternatives that leave no trace.
- **Source:** PR review session where three local `pr-*` branches were created across three separate review invocations; the user pointed out this shouldn't happen.
