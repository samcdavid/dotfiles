## Requirements Audit: [Feature/Ticket]
Date: [ISO timestamp]
Spec sources: [Linear ticket, Notion doc, PR description]

### Summary
[2-3 sentences: overall coverage assessment — is the feature complete, partial, or significantly gapped?]

### Traceability Matrix
| # | Requirement | Status | Code | Tests | Notes |
|---|------------|--------|------|-------|-------|
| R1 | [Criterion] | Covered | `file:line` | `test:line` | |
| R2 | [Criterion] | Partial | `file:line` | — | [what's missing] |
| R3 | [Criterion] | Missing | — | — | [intentional or overlooked?] |

### Coverage: [N/M requirements covered] ([percentage]%)

### Missing or Incomplete Requirements
#### 1. [Requirement text]
**Status:** Missing / Partial
**Impact:** [What the user won't be able to do, or what will behave unexpectedly]
**Recommendation:** [Implement before merge / Defer with ticket / Acceptable as-is with documentation]

### Edge Case Gaps
#### 1. [Scenario]
**Requirement:** R[N]
**What happens:** [Current behavior when this edge case occurs]
**What should happen:** [Expected behavior based on spec or reasonable inference]
**Risk:** [Data loss / Bad UX / Error / Silent failure]

### Scope Analysis
#### Scope Creep (code not traced to requirements)
- `file:line` — [what it does, whether it should be separate]

#### Scope Contraction (requirements not fully addressed)
- R[N] — [what was deferred or simplified]

### User-Facing Behavior Changes
| Change | Intentional | Requirement | Notes |
|--------|------------|-------------|-------|
| [Description] | Yes/No/Unclear | R[N] or — | |

### Positive Findings
- [Requirements well-covered, good test strategy, clean scope]

### Considered and Dismissed
- [Findings that failed adversarial review]

### Recommendations
1. [Prioritized actions — what must happen before merge vs. what can follow up]
```
