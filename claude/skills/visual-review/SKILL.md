---
name: visual-review
description: "Run my-review on a change and present it as a self-contained HTML page: the flow from user interaction to response, a check that every entry point follows the same rules, and the review's findings, verdict, and acknowledgements anchored to that flow, with the review drafted to post."
effort: xhigh
---

Review $ARGUMENTS with `my-review` and present the result as one HTML page, ending in the review it drafted for me to edit and post. The review is `my-review`'s: its triage, orchestrator, adversarial challenges, importance filter, and verdict stand, and you add no analysis of your own beyond the flow and entry points below. You never post it.

**Trace the flow.** Follow the change from the user's action (click, submit, API call, import, job) through every layer it touches to the response they see, including the failure and empty paths. Read the code around each changed hunk, not only the hunk. Every node is `added`, `modified`, `removed`, or `context` (unchanged but needed to follow the path) and cites `file:line`. Draw the runtime path, never a file list. Collapse unchanged stretches into one context node. Don't draw a node you haven't read. Read a PR only through `gh` at its head, as `my-review` does; for local changes diff against the default branch's merge-base, uncommitted changes included. If there's nothing to show, say so and stop.

**Entry points.** Name the capability the change touches, then find and classify every other way to reach it, and compare the rules each applies, as `references/entry-points.md` describes. Flag any new implementation of functionality that already exists, whether parity with the old one is intended, and any rule the change applies on one path but not the others.

**Draw every entry point.** Number the table rows E1, E2, … (`<tr id="E1">`) and give each a node in the flow's first lane with an `E1` chip (`<a class="badge entry" href="#E1">`): no row without a node, no node without a row. A `shared` row's node has a `next` edge into the shared node, and its text names any rule that differs. A `bespoke` row's own nodes are chained with `bespoke` edges, from its entry node to where it rejoins the shared path, so the second implementation reads as its own lane. Mark a row this change adds `new` and draw its nodes `added`.

**Edges.** A JSON list in `<script type="application/json" id="edges">`, each with `from`, `to`, `kind`, `note`, and `href`. `kind` is `next`, `fail` (a failure path), `bespoke`, or `removed` (a connection this change deletes). `note` says what happens at the connection. `href` links the line where it is made, so clicking the edge opens it.

**Review.** Follow `my-review/SKILL.md` on the same target, Steps 1 to 7, with three changes:
- Security and Architecture always run, alongside the lenses its triage picks.
- Add the entry-point drift you found (a `bespoke` plus `new` row, a rule applied on one path and not the others) to its findings before Step 6, so it is challenged and filtered like the rest.
- Don't stop for Targeted Questions or publish: log the questions as its auto-mode does, and let the page post the review.

After Step 6, drop what the product doesn't support, as `references/context.md` says.

**Risks.** Two lists, product and technical, each risk anchored to a node with `file:line` and a confidence (high: visible in the diff; medium: depends on code you haven't seen; low: a hunch). Product: user-visible behavior, states and copy, permissions per role, existing data and in-flight work, rollout, and inconsistency between entry points. Technical: the lenses in the Lens catalog of `my-review/SKILL.md` whose trigger signals appear in the diff. In a review these are `my-review`'s surviving findings, not a second pass; `references/page.md` maps them.

**Verify.** Check every risk, entry-point intent, and flow claim against the repo's `docs/` and Linear, as `references/verify.md` says, reusing what `my-review` already fetched. Each risk shows `confirmed`, `contradicted` (dismiss or downgrade it), or `unsupported`.

**GitHub links.** For a PR, every `added`, `modified`, or `removed` node, every risk, every entry-point row, and every edge links to its code, as `references/github-links.md` says, and `<main>` gets `data-pr` set to the PR number. For local changes there is nothing to link or post: remove `data-pr`, the links, the review section, and its draft.

**Review draft.** Fill the page's review and suggested review type as `references/review-draft.md` says.

**Page.** Copy `references/template.html` to `${TMPDIR:-/tmp}/visual-review/<pr-number-or-branch>.html` (`/` in a branch name becomes `-`) and replace its placeholder content as `references/page.md` says. Write only that file, outside the repo. Keep it self-contained: no CDN or network request. The footer lists what you searched and couldn't verify; label unverified claims `unverified` rather than asserting them.

After each rewrite, run `sh references/open-page.sh <page>`. It loads the page headless and lists its "This page has gaps" warnings (rows, nodes, edges, lenses, or links that disagree), which you fix before running it again, and it opens the page in the browser once, the first time it is clean. Never run `open` yourself or open the page any other way. To change the page afterward, rewrite the file and tell me to refresh. Reply with its path, two or three sentences on the flow, `my-review`'s verdict with its reason and the findings that decided it, the entry-point drift, and what was dismissed and why, so I can overrule it.
