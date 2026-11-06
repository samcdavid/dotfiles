# What the product supports

`my-review` judges a change against the requirements it found. It doesn't ask what the product has chosen not to support, and a comment asking for that costs the author a reply and proves nothing. This is the one filter the page adds to its findings.

**Look.** For each finding that survives Step 6, check:
- Product decisions: out-of-scope lists, non-goals, and decisions made in comments in the Linear issue, milestone, and project, and the repo's `docs/` (ADRs, product rules, documented limits). `my-review`'s requirements checklist has already fetched them.
- Intent and limits the author stated in the PR's conversation, which Step 1 already indexed.
- The system itself: something along the flow or its neighbors that already handles it, such as a router pipeline or plug, a policy, a database constraint, a uniqueness or retry setting, a feature flag, a framework guarantee, or an upstream proxy.
- How sibling features handle the same concern. An established convention is what the system supports, even where you'd design it differently.

**Show it.** The page's System context list holds the few items that shaped the review, each with its source link: `supports`, `not supported` (a decision), `guarded` (something already handles it; draw it as a `context` node if it is on the path), and `convention`. If nothing turns up, one `none` item says what was searched.

**Dismiss.** A finding goes under Considered and dismissed, one line each with a reason chip and a link to its source, when:
- `out of scope`: a source says the product doesn't support what the finding asks for.
- `handled elsewhere`: a guard already covers it. Link the guard.
- `contradicted`: a source says the claim is wrong.

List what `my-review` itself dropped or deferred there too, with `already raised` (link the thread) or `below the bar` (the importance filter's DROP or DEFER; no link needed). A dismissed finding gets no card and no draft comment. A body line is allowed only to validate an `already raised` one, as `review-draft.md` says. The list stays on the page so I can overrule it by adding my own comment in the review section.

**Safeguards.**
- Dismiss a security or data-loss finding only on cited evidence, the source or the guard's code, never on judgment. A false positive kept beats a real one missed.
- Where a source is silent about what the product supports, keep the finding and phrase it as a question.
- The reverse is a finding: a change that adds or alters something a source says the product doesn't support, or that contradicts the docs, is a product risk.
