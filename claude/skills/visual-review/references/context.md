# System context

Judge the change against the system it lives in, not an ideal one. A comment asking for something the product doesn't support costs the author a reply and proves nothing, so learn what is supported before anything is drafted.

**Sources.**
- Product decisions: the Linear issue, milestone, and project from `verify.md`, taking their out-of-scope lists, non-goals, and decisions made in comments, and the repo's `docs/` (ADRs, product rules, documented limits).
- The PR's conversation, for a PR: the description, `gh api repos/{owner}/{repo}/pulls/{n}/comments`, `.../pulls/{n}/reviews`, and `.../issues/{n}/comments`, paginated. Authors state intent and limits there, and a thread may already raise your risk. If an earlier review of mine is among them, treat this as a re-review: re-read the whole diff and every thread, and check whether its points still hold.
- The system itself: for each candidate risk, look along the flow and its neighbors for something that already handles it, such as a router pipeline or plug, a policy, a database constraint, a uniqueness or retry setting, a feature flag, a framework guarantee, or an upstream proxy. Check how sibling features handle the same concern. An established convention is what the system supports, even where you'd design it differently.

**Show it.** The page's System context list holds the few items that shaped the review, each with its source link: `supports`, `not supported` (a decision), `guarded` (something already handles it; draw it as a `context` node if it is on the path), and `convention`. If nothing turns up, one `none` item says what was searched.

**Filter.** Run every candidate risk through `my-review/references/importance-filter.md` at `moderate`, the bar `my-review/SKILL.md` Step 6 sets while Architecture is active. Keep a risk only if you can finish "if this ships, ___ happens" with a concrete consequence you have evidence for. Everything else goes under Considered and dismissed, one line each, with a reason chip and a link to its source:
- `out of scope`: a source says the product doesn't support what the risk asks for.
- `handled elsewhere`: a guard already covers it. Link the guard.
- `contradicted`: a source says the claim is wrong.
- `already raised`: a thread in the PR covers it. Link the thread.
- `below the bar`: style, preference, speculation, or cheap to change later. This one needs no link.

A dismissed risk gets no card and no draft comment, and a body line only to validate an `already raised` one, as `review-draft.md` says. The list stays on the page so I can overrule it by adding my own comment in the review section.

**Safeguards.**
- Dismiss a security or data-loss risk only on cited evidence, the source or the guard's code, never on judgment. A false positive kept beats a real one missed.
- Where a source is silent about what the product supports, keep the risk and phrase it as a question.
- The reverse is a finding: a change that adds or alters something a source says the product doesn't support, or that contradicts the docs, is a product risk.
