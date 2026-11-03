---
name: visual-review
description: "Build a self-contained HTML page that diagrams a change's runtime flow from user interaction to response, calls out product and technical risks, and checks that every entry point to the same feature follows the same rules."
effort: xhigh
---

Build a visual review of $ARGUMENTS as one HTML file. This is not a review: no verdict, severity, or approve/block language. If I ask for one, point me to `/my-review`.

**Target.** For a PR, read the diff and files at the PR head with `gh` (`gh pr diff`, `gh api .../contents/{path}?ref={sha}`). Never check it out, and never treat the local working tree as PR contents. Without a PR, diff against the merge-base with the default branch, uncommitted changes included. If there's nothing to show, say so and stop.

**Trace the flow.** Follow the change from the user's action (click, submit, API call, import, job) through every layer it touches to the response they see, including the failure and empty paths. Read the code around each changed hunk, not only the hunk. Every node is `added`, `modified`, `removed`, or `context` (unchanged but needed to follow the path) and cites `file:line`. Draw the runtime path, never a file list. Collapse unchanged stretches into one context node and keep the diagram near 15 nodes. Don't draw a node you haven't read.

**Entry points.** Name the capability the change touches (for example "create a question"). Find every other way to reach it: other UI surfaces, API/GraphQL/MCP, bulk import, clone or duplicate, templates, jobs, seeds, admin tools. Search for every writer of the same schema and every caller of the same core function, and record what you searched. Mark each entry point `shared` (reaches the same core), `bespoke` (reimplements it), or `new` (added by this change). For each, compare the rules it applies: validation, defaults, authorization, limits, side effects (events, jobs, notifications, analytics, audit), flags, and error and UI copy. Flag a rule the change applies on one path but not the others, and any new path that forks instead of reusing the core. A bespoke path is drawn as a bypass edge around the shared core.

**Risks.** Keep product and technical risks in two lists, each anchored to a node, with `file:line` and a confidence (high: visible in the diff; medium: depends on code you haven't seen; low: a hunch). Product: user-visible behavior, states and copy, permissions per role, existing data and in-flight work, rollout, and any inconsistency between entry points. Technical: the lenses in the Lens catalog of `my-review/SKILL.md` whose trigger signals appear in the diff. Raise, don't investigate beyond the code you read for the flow. Fetch nothing from Linear or docs.

**Page.** Copy `references/template.html` to `~/.thoughts/visual-review/<pr-number-or-branch>.html` and replace its placeholder content. Write only that file, outside the repo. Edges are drawn from each node's `data-to` (next step), `data-err` (failure path), and `data-bypass` (bespoke path); delete unused lanes, nodes, and rows. Keep it self-contained: no CDN, font, or network request. List what you searched and couldn't verify in the footer, and label unverified claims `unverified` rather than asserting them.

Open the page (`open`, or `xdg-open` on Linux) and reply with its absolute path, two or three sentences on the flow, and the high-confidence risks and entry-point drift.
