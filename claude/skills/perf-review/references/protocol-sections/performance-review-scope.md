## Performance Review: [Scope]
Date: [ISO timestamp]

### Critical Findings (will cause incidents under load)
#### 1. [Category]: [Title]
**Location:** `file:line`
**Impact:** [What breaks and at what scale]
**Evidence:** [Query plan, resource trace, or load estimate]
**Fix:** [Concrete remediation with code]
**Expected improvement:** [Quantified where possible]

### High Findings (degraded performance, fix before release)
...

### Medium Findings (optimization opportunities)
...

### Low Findings (marginal improvements)
...

### Query Summary
| Query Location | Type | Index Used | Estimated Cost | Issue |
|---------------|------|-----------|----------------|-------|

### Resource Profile
| Resource | Current Usage Pattern | Risk | Mitigation |
|----------|---------------------|------|------------|

### Caching Opportunities
| Data | Access Pattern | Suggested Strategy | Invalidation |
|------|---------------|-------------------|-------------|

### Positive Patterns
- [Things done well — efficient queries, good caching, proper batching]

### Considered and Dismissed
- [Findings that failed adversarial review — what was considered and why it was dropped]

### Recommendations
1. [Prioritized next steps, ordered by impact]
```
