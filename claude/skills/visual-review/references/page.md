# From the review to the page

The page renders the review `my-review` produced and finds nothing it didn't. Each part of that review has one place:

| `my-review` output | On the page |
|---|---|
| Triage intent, Summary | The header summary, and the opening of the review body. |
| Lenses identified and each deep-dive block | The Lenses table, below. |
| Blocking Issues, Non-blocking Suggestions, deep-dive findings, Related-Issue Regression Risks, and the entry-point drift you added | Risk cards anchored to a node, each with its lens chip and `data-lens`. Confidence follows the importance filter: Verified is high, Plausible is medium. A finding with no line in the diff is still a card, and goes in the review body. |
| Requirements checklist, Requirements Traceability, docs read | The System context list (`context.md`) and each card's verification line (`verify.md`). |
| Human Acknowledgements | Needs your confirmation, below. |
| Dropped Findings, DEFERs, and what the context filter drops | Considered and dismissed, a line and a reason chip each (`context.md`). |
| Questions, What's Good | The review body (`review-draft.md`). |
| Verdict and its sentence | The suggested review type (`review-draft.md`). |

**Lenses table.** A row for every lens that ran, `data-lens` set to its lowercase name, Security and Architecture always:
- why it ran, naming its trigger in the diff (Security and Architecture say "always");
- what it checked on the flow, naming nodes and entry points, never just "reviewed";
- what it found, as links to its risk cards. A lens that found nothing says so and says what it checked, and links any finding it dismissed.

Every risk carries its lens as a chip beside its title and as `data-lens`, and its lens row links it.

**Needs your confirmation.** One item per Human Acknowledgement, A1, A2, …, each with its category chip, what changed, the ask, and its `file:line`, or one `none` item. They are not defects and never change the verdict. Each also has a comment in the review draft, as `my-review` always drafts one. Where a thread already asks it, mark the item "already asked" and link the thread, and draft no comment. Where the author has answered, mark it "author answered" and link the answer, and still draft the comment. Local changes have no review section, so the list is the Pending before PR checklist.
