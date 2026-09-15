# Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The tests pass, so it's fine" | Green tests are necessary, not sufficient — they don't catch architecture, security, or requirements gaps. Read the diff itself. |
| "CI is red, I should dig into why" | Out of scope. CI reports its own findings on its own surface, and `ci-babysit` owns pipeline triage. Checking `gh pr checks` feels diligent but spends the review's budget re-deriving what the author already sees. |
| "Another reviewer blocked on red CI, so CI state is decision-relevant" | Their blocker, not yours. Note it from `existing_comments_index` and move on. This is the specific rationalization that has actually triggered a CI rabbit hole — see `gotchas.md`. |
| "It's a small PR, a light pass is enough" | Diff size doesn't predict risk. A five-line change to auth or a migration deserves the same scrutiny as a five-hundred-line refactor. |
| "This finding is annoying but not really Critical" | Match severity to `review-finding-format.md`'s bar, not to how strongly it feels in the moment. If it doesn't meet a Critical criterion, it's non-blocking — say so plainly instead of inflating it to force a fix. |
| "The author clearly knows what they're doing" | Author competence isn't evidence the diff is correct. Review the code in front of you, not your prior of the author. |
| "I already found a few issues, that's enough" | Stopping early because a quota feels met leaves real findings on the table — finish the lens sweep before triaging. |
| "The PR conversation probably already covers this" | Confirm it actually does by checking `existing_comments_index` — don't silently drop a finding on a hunch. |
| "This is worth mentioning even though there is no concrete action" | Review feedback consumes author attention. If you cannot name the change, decision, or information needed to resolve a present diff-caused risk, drop it. |
| "The env var/flag/migration looks correct in code, so human confirmation is unnecessary" | Repository correctness cannot prove values exist in every staging/production environment or that a migration ran successfully in staging. Keep the readiness request separate from risk. It withholds PR approval, while local review still returns its independent code verdict and lists the pre-stage check. |
| "The linked issue is not complete or user-facing, so this PR cannot be approved" | Review the declared delivery increment. Internal groundwork and partial delivery can merge when the promised slice is coherent, safe, tested, and accurately leaves later integration or handoff outside its scope. |
| "COMMENT vs APPROVE doesn't matter much here" | It is mode-constrained. COMMENT exists only for a third-party PR. Local review always returns a code verdict; self-authored/unknown PR approval still requires operational readiness. |
