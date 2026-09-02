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
[PR only: one human-acknowledgement annotation at the primary changed-line anchor,
listing all migration/environment-variable/feature-flag/config/infra/linter-
suppression and modified-existing-test anchors, plus the exact operational
confirmation still required.
This is publishing input, not review-body prose. Do not repeat it elsewhere.]

[When a verified Critical or High-risk finding short-circuited lower-tier
fact-checking, also include one inline comment per Medium/Low-risk candidate:
**Not independently fact-checked:** A verified higher-priority finding consumed
the review's fact-checking budget. This observation was not independently
verified and does not affect the verdict; please assess whether `<observation>`
at `<path:line>` needs action.]

### Unverified Priority-Bypass Notices
**Fact-check status:** Medium/Low-risk candidates were not independently
fact-checked because verified Critical or High-risk findings were prioritized.
They do not affect the verdict.

#### 1. [Category]: [Concise observation]
**Risk (unverified lens estimate):** Medium | Low
**File:** `path/to/file.ext:LINE`
**Author notice:** [Observation to assess; not a verified defect]

### Security Deep-Dive
[Only when returned by the relevant lens]

### Architecture Assessment
[Only when returned by the relevant lens]

### Performance Deep-Dive
[Only when returned by the relevant lens]

### Quality Deep-Dive
[Only when returned by the relevant lens]

### Requirements Traceability
[Only when returned by the relevant lens. Show each eventual-feature
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

Omit empty conditional sections. Do not add a "What's Good" section: lens
reviewers no longer return verified positives, so the orchestrator would be
inventing praise.
