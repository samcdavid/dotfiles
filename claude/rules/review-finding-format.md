# Review Finding Format

Review findings must be grounded and actionable.

## Severity Bar

`REQUEST_CHANGES` blocks merging. Reserve it for **Critical** findings only:

- The PR is likely to break production or a core workflow.
- The PR can lose, corrupt, or expose data.
- The PR creates an exploitable security or privacy issue.
- The PR breaks a cross-service, API, or persistence contract with likely runtime impact.
- The PR omits a must-have acceptance criterion that makes the feature objectively incomplete for launch.

Everything else should be a non-blocking comment, question, suggestion, or nit, even when it is worth fixing. Do not request changes for style, preference, cleanup, ordinary missing tests, maintainability concerns, minor performance concerns, or speculative risk.

Approval still has a bar: approve only when the PR satisfies requirements and no Critical finding survives review. If there are several substantive inline comments, unresolved requirements questions, or enough non-blocking concerns that approval would overstate confidence, use `COMMENT`.

Use `blocking` only as shorthand for "Critical merge blocker." If a finding is important but not Critical, call it non-blocking and explain the risk.

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
