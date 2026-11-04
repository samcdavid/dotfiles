---
name: visual-review
description: "Build a self-contained HTML page diagramming a change's flow from user interaction to response, with product and technical risks read through security, architecture, and other review lenses and judged against what the product supports, a check that every entry point follows the same rules, and a review drafted to post."
effort: xhigh
---

Build a visual review of $ARGUMENTS as one HTML file, ending in a review drafted for me to edit and post. You never post it and you pick no verdict: no approve, request-changes, or severity language.

**Target.** For a PR, read the diff and files at the PR head with `gh` (`gh pr diff`, `gh api .../contents/{path}?ref={sha}`); never check it out or use the working tree as PR contents. Otherwise diff against the default branch's merge-base, uncommitted changes included. If there's nothing to show, say so and stop.

**Trace the flow.** Follow the change from the user's action (click, submit, API call, import, job) through every layer it touches to the response they see, including the failure and empty paths. Read the code around each changed hunk, not only the hunk. Every node is `added`, `modified`, `removed`, or `context` (unchanged but needed to follow the path) and cites `file:line`. Draw the runtime path, never a file list. Collapse unchanged stretches into one context node. Don't draw a node you haven't read.

**Entry points.** Name the capability the change touches, then find and classify every other way to reach it, and compare the rules each applies, as `references/entry-points.md` describes. Flag any new implementation of functionality that already exists, whether parity with the old one is intended, and any rule the change applies on one path but not the others.

**Draw every entry point.** Number the table rows E1, E2, … (`<tr id="E1">`) and give each a node in the flow's first lane with an `E1` chip (`<a class="badge entry" href="#E1">`): no row without a node, no node without a row. A `shared` row's node has a `next` edge into the shared node, and its text names any rule that differs. A `bespoke` row's own nodes are chained with `bespoke` edges, from its entry node to where it rejoins the shared path, so the second implementation reads as its own lane. Mark a row this change adds `new` and draw its nodes `added`.

**Edges.** A JSON list in `<script type="application/json" id="edges">`, each with `from`, `to`, `kind`, `note`, and `href`. `kind` is `next`, `fail` (a failure path), `bespoke`, or `removed` (a connection this change deletes). `note` says what happens at the connection. `href` links the line where it is made, so clicking the edge opens it.

**Risks.** Two lists, product and technical, each risk anchored to a node with `file:line` and a confidence (high: visible in the diff; medium: depends on code you haven't seen; low: a hunch). Product: user-visible behavior, states and copy, permissions per role, existing data and in-flight work, rollout, and inconsistency between entry points. Technical: the lenses in the Lens catalog of `my-review/SKILL.md` whose trigger signals appear in the diff.

**Lenses.** Security and Architecture always run, and so does every other lens in the Lens catalog of `my-review/SKILL.md` whose trigger signals appear in the diff (PM whenever there are requirements). Read the flow once per lens, taking its checks and leaving its procedure: every node, edge, and entry point is a place they can fail. Tag each risk with its lens. The page lists every lens with what it checked and found, so a clean lens shows it ran. See `references/lenses.md`.

**Context.** Judge the change against the system it lives in, not an ideal one. Before keeping a risk, learn what the product supports and has chosen not to, what the system already guards, and what the PR's conversation has raised, as `references/context.md` says. A risk the product doesn't support, the system already handles, the PR already raised, or that falls below the importance bar is dismissed with its reason and source, never drafted as a comment. Dismiss a security or data-loss risk only on cited evidence.

**Acknowledgements.** Scan the whole diff for the triggers in `my-review/references/human-acknowledgement.md` (migrations, env vars, flags, config, infra, lint suppressions, changed existing tests). List each as A1, A2, … under Needs your confirmation with its category, what changed, the ask, and its `file:line`, or say none. They are not defects: no lens, risk card, or draft comment.

**Verify.** Check every risk, entry-point intent, and flow claim against the repo's `docs/` and Linear, as `references/verify.md` says. Each risk shows `confirmed`, `contradicted` (dismiss or downgrade it), or `unsupported`.

**GitHub links.** For a PR, every `added`, `modified`, or `removed` node, every risk, every entry-point row, and every edge links to its code, as `references/github-links.md` says, and `<main>` gets `data-pr` set to the PR number. For local changes there is nothing to link or post: remove `data-pr`, the links, the review section, and its draft.

**Review draft.** Fill the page's review as `references/review-draft.md` says.

**Page.** Copy `references/template.html` to `${TMPDIR:-/tmp}/visual-review/<pr-number-or-branch>.html` (`/` in a branch name becomes `-`) and replace its placeholder content. Write only that file, outside the repo. Keep it self-contained: no CDN or network request. Off-page links open in a new tab, which the template's script enforces. The page warns when rows, nodes, edges, or links disagree. The footer lists what you searched and couldn't verify; label unverified claims `unverified` rather than asserting them.

Open the page once, after it is final (`open`, or `xdg-open` on Linux). To change it later, rewrite the file and tell me to refresh. Reply with its path, two or three sentences on the flow, the high-confidence risks and entry-point drift, and what you dismissed and why, so I can overrule it.
