# Review Output Template

Load during Step 5 of `protocol.md`.

```markdown
## Review: [Brief description of what the change does]

### Overall Change Risk
**Low** / **Medium** / **High** — [aggregate-diff rationale]

### Code Verdict
**APPROVE** / **REQUEST_CHANGES** — [whether the code change itself should move
forward. Always present this in local modes.]

### Acknowledgement Status
**PR:** eligible / pending human confirmation
**Local:** pre-stage human acknowledgement clear / required — [name each
environment-variable, feature-flag, migration, config, infrastructure,
suppression, or modified-existing-test item]

### Delivery Increment
**Promised now:** [the concrete outcomes reviewed in this change]
**User-facing now:** yes / no
**Deferred integration or handoff:** [what remains, plus the next step or owner when known]

### PR Verdict
**APPROVE** / **COMMENT** / **REQUEST_CHANGES** / **none — needs input** — [PR
mode only. Pending PR operational readiness never returns APPROVE.]

### Summary
[1-2 sentences demonstrating you understood the change and its purpose]

### Critical Findings

#### 1. [Category]: [Concise issue title]
**Risk:** [High | Medium | Low] · **Confidence:** [0–100] · **Verification:** [Opus verified | Sonnet targeted verification | not independently verified]
**File:** `path/to/file.ext:LINE`
**Problem:** [What's wrong and why it matters]
**Fix:** [Concrete code suggestion — copy-pasteable when useful]

### Non-blocking Suggestions

#### 1. [Category]: [Concise title]
**Risk:** [High | Medium | Low] · **Confidence:** [0–100] · **Verification:** [Opus verified | Sonnet targeted verification | not independently verified]
**File:** `path/to/file.ext:LINE`
**Suggestion:** [What to improve and why, with an example when useful]

### Prepared Inline Comments
[PR only: one human-acknowledgement annotation at the primary changed-line anchor,
listing all migration/environment-variable/feature-flag/config/infra/linter-
suppression and modified-existing-test anchors, plus the exact operational
confirmation still required.
This is publishing input, not review-body prose. Do not repeat it elsewhere.]

### Unverified Actionable Findings
[Include every actionable finding that did not receive independent verification.
They are verdict-neutral by default, regardless of severity or risk.]

#### 1. [Category]: [Concise issue title]
**Risk:** [High | Medium | Low] · **Confidence:** [0–100] · **Verification:** not independently verified
**File:** `path/to/file.ext:LINE`
**Problem:** [What the whole-diff worker observed and why it may matter]
**Suggested action:** [Concrete code, test, documentation change, decision, or author-only information request]
**Verdict impact:** Does not affect the verdict without independent verification.

### Security Deep-Dive
[Only when returned by the whole-diff worker]

### Architecture Assessment
[Only when returned by the whole-diff worker]

### Performance Deep-Dive
[Only when returned by the whole-diff worker]

### Quality Deep-Dive
[Only when returned by the whole-diff worker]

### Requirements Traceability
[Only when returned by the whole-diff worker. Show each eventual-feature
requirement's delivery classification so deferred work is not mistaken for a
current defect.]

### Related-Issue Regression Risks
[Only when returned by the tracer]

### Upcoming Project Work
[Only when an active/upcoming issue exactly covers a duplicate non-blocking follow-up]

### Questions
- [Exact author-only information or decision needed to resolve a changed-line risk]

### Dropped Findings
- [What a verifier dropped and why]
```

Omit empty conditional sections. Do not add a "What's Good" section: the
whole-diff worker does not return verified positives, so the orchestrator would
be inventing praise.
