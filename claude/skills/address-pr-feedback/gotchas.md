# Gotchas

## Reconcile feedback with the workflow ledger before accepting it

- **Trigger:** Any review finding on a branch with a `my-workflow` ledger.
- **Wrong behavior:** Classify a plausible review comment as a fix before checking whether it conflicts with a settled ledger decision, plan constraint, or documented scope boundary.
- **Correct behavior:** Verify every finding against the ledger first. If it conflicts, push back with the ledger's specific decision and rationale; implement only when new evidence or an explicit user decision supersedes it.
- **Why it matters:** The ledger is the durable record of accepted trade-offs, so ignoring it reopens decisions that the workflow has already settled.

## Complete the PR feedback publication sequence

- **Trigger:** PR-mode triage is confirmed and reply publication is authorized.
- **Wrong behavior:** Post replies but unilaterally leave the review threads open.
- **Correct behavior:** After replies succeed, resolve every addressed inline thread, then re-request eligible non-approving reviewers unless the user explicitly narrows that scope.
- **Why it matters:** Open threads leave resolved feedback looking unfinished and make the PR's review state misleading.
