## Final report & hand-off

After the post-review loop converges (or escalates), assemble one consolidated report from the ledger:

- **Task & entry point** — what ran, what was skipped and why.
- **Artifacts produced** — paths to research / spec / plan / observability / analysis / validation reports.
- **Decisions you made** — the decision points where the pipeline paused and what you chose. (These are the user's calls, captured for the record.)
- **Autonomous assumptions** — the full list of *factual* assumptions from the ledger (the things research resolved). This is the after-the-fact review surface; make it scannable. No genuine decision should appear here — decisions live in the section above.
- **Findings by severity** — present the final `my-review` verdict (the pass that converged the loop) grouped Critical → Minor. Note how many loop iterations it took to reach zero findings.
- **What I changed** — files touched (paths + line counts), tests run + results.
- **Suggested next steps** — `/commit`, then `/create-pr`; and re-run a specific stage if any finding is substantial.

End with the explicit boundary:
> No git actions were taken. You approved the spec and plan along the way; the pipeline self-reviewed its own code (the `my-review` stage) — treat the findings and assumptions above as the review surface before committing.
