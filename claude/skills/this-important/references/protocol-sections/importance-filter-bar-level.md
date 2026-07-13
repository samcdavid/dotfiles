## Importance Filter ([bar level])

### Kept ([N])
| # | Finding | Severity | Why It Matters |
|---|---------|----------|----------------|
| 1 | [summary, file:line] | Blocking | [concrete consequence of not acting] |

### Downgraded ([N])
| # | Finding | Was | Now | Reason |
|---|---------|-----|-----|--------|
| 1 | [summary] | Blocking | Non-blocking | [why lower severity is right] |

### Deferred ([N])
| # | Finding | Reason | Follow-up |
|---|---------|--------|-----------|
| 1 | [summary] | High cost-of-action, low cost-of-inaction | [ticket / next-PR / specific plan] |

### Dropped ([N])
| # | Finding | Why Dropped |
|---|---------|-------------|
| 1 | [summary] | [specific reason: speculative, pure style, duplicate, low impact + easy to fix later, etc.] |

### Bar Calibration Notes
[1–2 sentences: was the bar applied consistently? Any close calls worth surfacing to the user?]
```
