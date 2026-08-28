# Review Output Template

Load during Step 5 of `protocol.md`.

```markdown
## Review: [Brief description of what the change does]

### Overall Change Risk
**Low** / **Medium** / **High** — [aggregate-diff rationale]

### Approval Status
**eligible** / **pending human confirmation** — [name any unconfirmed environment-variable, feature-flag, or migration readiness conditions]

### Verdict
**APPROVE** / **COMMENT** / **REQUEST_CHANGES** / **none — needs input** — [why this verdict or pending state applies. COMMENT is valid only for a third-party PR; pending operational readiness never returns APPROVE.]

### Summary
[1-2 sentences demonstrating you understood the change and its purpose]

### Critical Findings

#### 1. [Category]: [Concise issue title]
**Risk:** [High | Medium | Low] · **Confidence:** [High | Medium | Low] · **Verified by:** [finding-verifier-high | finding-verifier-low]
**File:** `path/to/file.ext:LINE`
**Problem:** [What's wrong and why it matters]
**Fix:** [Concrete code suggestion — copy-pasteable when useful]

### Non-blocking Suggestions

#### 1. [Category]: [Concise title]
**Risk:** [High | Medium | Low] · **Confidence:** [High | Medium | Low] · **Verified by:** [finding-verifier-high | finding-verifier-low]
**File:** `path/to/file.ext:LINE`
**Suggestion:** [What to improve and why, with an example when useful]

### Prepared Inline Comments
[PR only: one human-review annotation at the primary changed-line anchor,
listing all migration/environment-variable/feature-flag/config/infra/linter-
suppression anchors and the exact operational confirmation still required.
This is publishing input, not review-body prose. Do not repeat it elsewhere.]

### Security Deep-Dive
[Only when returned by the relevant lens]

### Architecture Assessment
[Only when returned by the relevant lens]

### Performance Deep-Dive
[Only when returned by the relevant lens]

### Quality Deep-Dive
[Only when returned by the relevant lens]

### Requirements Traceability
[Only when returned by the relevant lens]

### Related-Issue Regression Risks
[Only when returned by the tracer]

### Upcoming Project Work
[Only when an active/upcoming issue exactly covers a duplicate non-blocking follow-up]

### Questions
- [Exact author-only information or decision needed to resolve a changed-line risk]

### Dropped Findings
- [What a verifier dropped and why]
```

Omit empty conditional sections. Do not add a "What's Good" section: lens
reviewers no longer return verified positives, so the orchestrator would be
inventing praise.
