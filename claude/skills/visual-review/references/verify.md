# Verify against docs and Linear

A finding is a claim. Check each against the repo's `docs/` and Linear before the page states it. Leave staging verification to QA.

**Find the sources.** Fetch them as the Requirements checklist section of `my-review/SKILL.md` describes: the Linear issue with its comments, milestone, project and project documents, and team context, then the docs for the changed area under `docs/`, starting from the `README.md` in `docs/guides/` and the app's `docs/guides/<app>/`. Read only what is relevant to the change.

**What to check.**
- **Each risk:** does a doc, the issue, or a comment confirm it, contradict it, or say nothing?
- **Each `bespoke` row:** does a source say the two implementations should behave the same, or that the new path is deliberate? That settles whether parity is intended.
- **The flow and entry points:** do the docs describe a different path, entry point, or rule than the code? A disagreement is a finding; say which side looks stale. Check a doc against the code before trusting it.
- **Behavior the change alters that a doc describes, with no doc update in the diff:** note it, and draft a comment asking for the update.
- **Requirements and acceptance criteria the diff doesn't cover:** a product risk.
- **Linear and the docs disagreeing with each other:** a question in the review body naming both.

**Show the outcome.** Every risk carries a verification line (`<p class="vf">`): `confirmed`, `contradicted`, or `unsupported` (no source speaks to it), with a link to each source. Drop or downgrade a `contradicted` risk. Link a doc as a blob at the head commit (the default branch for a plan) and an issue by its URL. If there is no issue, or no docs for the area, say so once in the footer rather than guessing.
