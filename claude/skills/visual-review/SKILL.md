---
name: visual-review
description: "Build a self-contained HTML page that diagrams a change's runtime flow from user interaction to response, calls out product and technical risks, and checks that every entry point to the same feature follows the same rules."
effort: xhigh
---

Build a visual review of $ARGUMENTS as one HTML file. This is not a review: no verdict, severity, or approve/block language. If I ask for one, point me to `/my-review`.

**Target.** For a PR, read the diff and files at the PR head with `gh` (`gh pr diff`, `gh api .../contents/{path}?ref={sha}`); never check it out or use the working tree as PR contents. Otherwise diff against the default branch's merge-base, uncommitted changes included. If there's nothing to show, say so and stop.

**Trace the flow.** Follow the change from the user's action (click, submit, API call, import, job) through every layer it touches to the response they see, including the failure and empty paths. Read the code around each changed hunk, not only the hunk. Every node is `added`, `modified`, `removed`, or `context` (unchanged but needed to follow the path) and cites `file:line`. Draw the runtime path, never a file list. Collapse unchanged stretches into one context node. Don't draw a node you haven't read.

**Entry points.** Name the capability the change touches (for example "create a question"), then find and classify every other way to reach it, and compare the rules each applies, as `references/entry-points.md` describes. Flag a rule the change applies on one path but not the others, and any new path that forks instead of reusing the core.

**Draw every entry point.** Number the table rows E1, E2, and so on (`<tr id="E1">`) and give each a node in the flow's first lane with an `E1` chip (`<a class="badge entry" href="#E1">`): no row without a node, no node without a row. A `shared` row gets a `data-to` edge to where the paths converge. A `bespoke` row gets a `data-bypass` edge to where it diverges: around the core if it reimplements it, into the core node if it reaches it under its own rules. Its node text names the rule that differs. Before you finish, confirm every row has a node and every bespoke node has `data-bypass`; the page shows a warning banner when they disagree.

**Risks.** Two lists, product and technical, each risk anchored to a node with `file:line` and a confidence (high: visible in the diff; medium: depends on code you haven't seen; low: a hunch). Product: user-visible behavior, states and copy, permissions per role, existing data and in-flight work, rollout, and inconsistency between entry points. Technical: the lenses in the Lens catalog of `my-review/SKILL.md` whose trigger signals appear in the diff. Don't investigate beyond the code you read for the flow, and fetch nothing from Linear or docs.

**Page.** Copy `references/template.html` to `${TMPDIR:-/tmp}/visual-review/<pr-number-or-branch>.html` (create the directory; `/` in a branch name becomes `-`) and replace its placeholder content. Write only that file, outside the repo. Edges come from each node's `data-to` (next step), `data-err` (failure path), and `data-bypass` (bespoke path); delete unused lanes, nodes, and rows. Keep it self-contained: no CDN, font, or network request. The footer lists what you searched and couldn't verify; label unverified claims `unverified`.

Open the page (`open`, or `xdg-open` on Linux) and reply with its path, two or three sentences on the flow, and the high-confidence risks and entry-point drift.
