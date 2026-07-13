## Step 4 — Adversarial Filter (Before Categorizing)

You now have a long candidate list. **Most of it should not reach the user.** Run every candidate through this filter:

1. **Already answered in the source?** Re-read the surrounding section. Authors often answer the question two paragraphs later. If answered → drop.
2. **Answered in the codebase or a linked doc?** If your Step 2 grounding resolved it → drop, and note the answer for the user as confirmed (not as a question).
3. **Inferable with reasonable confidence?** Could a competent engineer make a defensible default call? If yes → drop as a question, optionally note as an assumption to confirm.
4. **Would the answer change planning or implementation?** If both answers lead to the same downstream work → drop. Decorative ambiguity is not blocking.
5. **Truly independent?** If issue B's resolution depends on issue A's, collapse them into A.

When in doubt, run a quick adversarial pass on your draft list: spawn an `adversarial-debate` agent (or do it yourself, fresh-eyed) — "for each of these, steel-man why it's NOT actually blocking." Anything that can be steel-manned away should be downgraded or dropped.

The goal: a short list of high-signal issues. A report with 30 "blocking" issues is as useless as no report.
