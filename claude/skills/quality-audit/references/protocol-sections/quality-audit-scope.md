## Quality Audit: [Scope]
Date: [ISO timestamp]

### Summary
[2-3 sentences: overall test quality assessment — is the test suite trustworthy for this area?]

### Critical Findings (tests that give false confidence)
#### 1. [Category]: [Title]
**Location:** `test_file:line`
**Problem:** [Why this test doesn't catch what it claims to]
**Risk:** [What class of bug would slip through]
**Fix:** [Concrete test code or assertion to add/change]

### High Findings (significant coverage gaps)
...

### Medium Findings (test quality improvements)
...

### Low Findings (minor improvements)
...

### Coverage Matrix
| Production Code | Unit Tests | Integration Tests | Gaps |
|----------------|-----------|------------------|------|
| `file:function/arity` | `test:line` | `test:line` | [untested branches/paths] |

### Flakiness Risk
| Test | Risk Factor | Mitigation |
|------|------------|------------|
| `test_file:line` | [time/order/network/race] | [how to stabilize] |

### Test Architecture Assessment
- **Pyramid balance:** [healthy / top-heavy / bottom-heavy]
- **Placement:** [well-organized / misplaced tests identified]
- **Factory quality:** [solid / needs attention]

### Positive Patterns
- [Good testing practices to reinforce]

### Considered and Dismissed
- [Findings that failed adversarial review]

### Recommendations
1. [Prioritized actions — highest risk gaps first]
```
