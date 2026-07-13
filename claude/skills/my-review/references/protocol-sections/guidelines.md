## Guidelines

- Every Critical merge-blocking issue must include a concrete fix, ideally replacement code.
- Every non-blocking suggestion should include example code when the alternative is not obvious.
- Explicitly label severity on every comment: **Critical**, **Suggestion (non-blocking)**, **Question**, or **Nit**.
- Ask rather than demand when the author may have context you lack.
- Focus on substance; do not bikeshed formatting, naming, or style unless genuinely confusing.
- Cross-service boundaries deserve extra scrutiny because subtle bugs hide there.
- Tests must test what they claim; vacuous tests are worse than no tests.
- Never re-raise an issue already present in the PR conversation.
- Reserve `REQUEST_CHANGES` for Critical merge blockers: likely production breakage, data loss/corruption/exposure, exploitable security/privacy risk, likely runtime contract break, or omitted must-have acceptance criteria. Non-Critical findings can be raised as comments, questions, suggestions, or nits; use `COMMENT` rather than `APPROVE` when there are several substantive inline comments or unresolved requirements concerns.
