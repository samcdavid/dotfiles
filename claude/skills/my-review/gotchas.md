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
