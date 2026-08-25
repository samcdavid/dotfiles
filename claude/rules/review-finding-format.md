# Review Finding Format

Review findings must be grounded and actionable.

## Severity Bar

`REQUEST_CHANGES` blocks merging. Reserve it for findings that are both
**Critical** and **High risk**. Critical describes the potential impact; High
risk means the failure is likely on a common path or has a wide blast radius.
Critical findings at Medium or Low risk are important non-blocking feedback,
not automatic merge blocks:

- The PR is likely to break production or a core workflow.
- The PR can lose, corrupt, or expose data.
- The PR creates an exploitable security or privacy issue.
- The PR breaks a cross-service, API, or persistence contract with likely runtime impact.
- The PR omits a must-have acceptance criterion that makes the feature objectively incomplete for launch.

Everything else should be a non-blocking comment, question, suggestion, or nit, even when it is worth fixing. Do not request changes for style, preference, cleanup, ordinary missing tests, maintainability concerns, minor performance concerns, speculative risk, or a Critical concern whose verified risk is not High.

Approval still has a bar: approve only when the PR satisfies requirements, no Critical High-risk finding survives, and all remaining findings are Low risk. Low-risk findings may be substantive and actionable. Use `COMMENT` whenever a non-blocking finding is Medium/High risk, requirements are unresolved, or context is insufficient.

Use `blocking` only as shorthand for a "Critical, High-risk merge blocker." If a finding is important but does not meet both bars, call it non-blocking and explain the risk.

## Format

```markdown
#### N. [Category]: [Title]
- **Severity:** Critical | Non-blocking | Question | Nit
- **File:** `path:LINE`
- **Problem:** what is wrong and why it matters
- **Fix:** concrete correction
- **Evidence:** code, diff, requirement, log, or doc supports claim
```

Drop findings that are stylistic, speculative, already raised, or lack plausible user-facing, production, security, data, maintainability, or test-quality consequence.
