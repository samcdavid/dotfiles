## Step 7 — Adversarial Verdict Challenge

Choose the PR review verdict adversarially. Always run this step before publishing or recommending a GitHub review state.

### Propose Verdict

- **APPROVE** — requirements are satisfied, no Critical findings survive, and only minor nits or clearly optional suggestions remain.
- **COMMENT** — no Critical finding survives, but approval would overstate confidence: several substantive inline comments, unresolved requirements questions, insufficient context, stale/already-merged PR state, or the user explicitly asks not to approve.
- **REQUEST_CHANGES** — at least one **Critical** merge blocker: likely production breakage, data loss/corruption/exposure, exploitable security/privacy risk, likely runtime contract break, or omitted must-have acceptance criterion.

### Challenge Verdict

Spawn `adversarial-debate` with:

- proposed verdict
- final surviving findings
- severity classification for each finding
- triage context and active lenses

Ask it to challenge both directions:

- Is the verdict too soft because a Critical issue is hidden in non-blocking sections?
- Is the verdict too harsh because a finding is important but not actually merge-blocking?
- If COMMENT: why not APPROVE? Are the inline comments substantive or numerous enough, or is requirement satisfaction uncertain?
- If APPROVE: do the changes satisfy the requirements, and are remaining comments only minor or optional?
- If `REQUEST_CHANGES`, is the worst finding genuinely Critical under the merge-blocking bar?

Apply the adversarial verdict before final output.
