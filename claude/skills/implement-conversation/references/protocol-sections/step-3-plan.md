## Step 3 — Plan

**Quick pipeline:** Invoke `quick-plan` with the task description and the research artifact path. It will inventory the work function-by-function, apply the TDD gate per phase (TDD for behavior changes, direct-edit for pure refactors), and write a plan file. Proceed immediately — `quick-plan` is self-approving.

**Full pipeline:** Invoke `my-plan` with the task description and the research artifact path. Follow its full process. Self-approve the plan (this is an autonomous pipeline — no additional confirmation is needed after the Step 0 touchpoint). Record the plan file path in the ledger.
