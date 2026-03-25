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
- **Source:** ENA-184 code conventions discussion

### Re-review means full re-review — don't coast on prior approval
- **Category:** failure-mode
- **Context:** User asks to review a PR that was previously reviewed (re-review request, re-requested review on GitHub, or author says "re-requesting your review")
- **Wrong:** Assuming the diff hasn't changed, skipping the full review process, or saying "my previous approval stands" without re-reading the diff and all comments. This misses: rebase conflict resolutions that changed your code, new comments from the author requesting specific attention, or fixes that addressed (or broke) your prior feedback.
- **Right:** Treat every re-review as a fresh review. Re-read the full diff, re-read ALL comments (including issue-level comments where authors often explain what changed), and check if your prior findings are still valid or have been addressed. Look specifically for: author comments mentioning conflicts, edits to your changes, or requests for specific attention.
- **Why:** PRs evolve between reviews — rebases resolve conflicts (sometimes incorrectly), authors address feedback (sometimes introducing new issues), and new comments add context. Coasting on a prior approval can miss rebase errors (as happened with #24481 where the author edited the reviewer's code during conflict resolution) or leave stale bug comments that should be retracted (as happened with #24470 where both flagged bugs were fixed but the comments were still open).
- **Source:** PR #24481 (CNVS-429) re-review — author rebased and edited reviewer's code; PR #24470 (ENA-172) re-review — prior bugs were fixed but comments not retracted until re-review
