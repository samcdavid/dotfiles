---
name: visual-plan
description: "Plan a Linear issue or project's implementation as a self-contained HTML page (requirements, planned flow from user interaction to response, entry-point consistency, slices, risks, open questions) and, once I confirm, attach it to that issue or project."
effort: xhigh
---

Build a visual implementation plan for $ARGUMENTS: a Linear issue key, a project identifier like `P-ENG-12`, a project name, or a URL. Plan only: never edit the repo, create a branch, or start building. For work that already exists, point me to `/visual-review`.

**Requirements.** Gather the sources as `visual-review/references/verify.md` describes, and for a project read every issue and milestone in it. Number each requirement and tag it with its source. Name what is out of scope. Answer questions from the code first (callers, tests, similar features, `git log`). Put only what the code, the docs, and Linear can't answer under Open questions, and ask me only if the plan can't be drawn without the answer.

**Planned flow.** Read the code the change will touch, then draw the flow from user interaction to response, failure paths included. Nodes are `to add`, `to change`, `to remove`, or `existing`, each with a `file:line`, or for new code the file where its nearest sibling lives. Don't draw a node you haven't read or can't place.

**Entry points and risks.** Apply `visual-review/references/entry-points.md` and the Draw every entry point and Risks paragraphs of `visual-review/SKILL.md`, forward-looking: for each entry point to the capability, say what the plan makes it do, and let its Path chip and edge show that planned state (an entry the plan converges is `shared`, with a `data-to` edge). Plan the change at the shared core so every entry point inherits it. Where an entry point is bespoke today, plan converging it or say why not. Never plan a new parallel path to something that already exists. Each risk names the slice that mitigates it. Verify the planned flow, each entry point, and each risk against the docs and Linear as `visual-review/references/verify.md` says, and show each risk's outcome.

**Slices.** Write 3 to 8, smallest useful first, one behavior each, test-backed (failing test first), ordered by dependency. Each lists its test, files, the nodes it touches, and the requirements and risks it covers. Every slice traces to a requirement, and every requirement to a slice or an open question. For a project, mark which issue each slice belongs to.

**Page.** Start from `visual-review/references/template.html` and splice in `references/plan-sections.html`: Requirements above the flow, Slices after the entry-point matrix, Open questions after the risks. Relabel the legend and tags to the planned wording and chip each node with its slice. Nothing is in a PR yet, so remove `data-pr`, the GitHub links and edge `href`s, the review section and its draft, the System context, Lenses, Needs your confirmation, and Considered and dismissed sections with each risk's lens chip and `data-lens`, and the legend entries for links, bespoke, and removed edges. Write it to `${TMPDIR:-/tmp}/visual-plan/<issue-or-project-key>.html` (create the directory) and open it once, after it is final; to change it later, rewrite the file and tell me to refresh. The OS temp directory cleans it up, so the copy attached to Linear is the lasting one. Keep it self-contained, and label unverified claims `unverified`.

**Attach.** Attaching publishes the plan to Linear. Tell me the exact action and wait for my OK, unless $ARGUMENTS includes `attach`.
- Issue: `prepare_attachment_upload` (`text/html`), PUT the bytes with `curl` and every returned header verbatim within 60 seconds, then `create_attachment_from_upload` titled "Implementation plan".
- Project, which takes no file attachments: `prepare_file_upload` and PUT the same way, then `save_document` on the project titled "Implementation plan" with a short summary (goal, slices, open questions) and the file's markdown link.

If the target already has a plan attachment or document, name it and ask before adding another. Never delete one. If a step fails, stop, report which, and leave the local file.

Reply with the page's absolute path, what was attached and where (or the pending action), two sentences on the plan, and the open questions.
