# Mode Semantics

Read before acting on feedback. The mode determines the feedback source, whether triage has a human gate, and which rules apply.

## PR mode

Default when a PR exists for the branch, or when `$ARGUMENTS` names one.

- Feedback source: GitHub review comments, review bodies, and issue comments, fetched with the filtered payloads in `pr-cost-control.md`.
- Truth: the PR diff at `pr_head_sha`, never the local working tree. `pr-mode-readonly.md` applies in full.
- Gate: **present triage and wait for confirmation** before changing code. Real reviewers are on the other end; pushing back on a colleague's comment is a judgment call the user owns. This is the *only* gate — per `no-outward-actions.md`, it is the explicit ask that authorizes everything downstream (implement, commit, push, publish replies, resolve threads, re-request review) to run to completion without a second confirmation.
- Output: evidence-backed replies drafted per comment, then pushed, posted, their threads resolved, and non-approving reviewers re-requested — all automatic once verification (Step 9) and self-audit (Step 10) pass.

## Local mode

Active when `$ARGUMENTS` says `local`, when findings are handed to you inline, or when no PR exists for the branch.

- Feedback source: `my-review`'s findings for the working tree, passed inline by the caller or taken from the conversation.
- Truth: the whole branch diffed against the base branch — `fork=$(git merge-base "$base_ref" HEAD); git diff "$fork"`, covering every commit added on the branch plus staged and unstaged work. Not `git diff HEAD~1` and not the bare working tree. `pr-mode-readonly.md` and `pr-cost-control.md` do **not** apply — there is no PR to be read-only about.
- Gate: **none.** State the triage and proceed. The reviewer is `my-review`, not a person, so there is nobody to negotiate with and nothing is gained by stopping.
- Output: resolution per finding. No replies, no GitHub calls of any kind.

### What to act on in local mode

Fix Critical findings and non-blocking findings substantive enough that shipping them would be sloppy. Do not spend a fix cycle on nits, style preferences, or clearly optional suggestions — carry those forward as deferred items so the caller can report them.

This matters because local mode usually runs inside `my-workflow`'s automatic fix loop, which is capped at 3 iterations. Burning an iteration on nits wastes a pass that a real finding may need.

### Pushing back in local mode

Push back exactly as rigorously as in PR mode — `references/pushback-patterns.md` still governs, and a finding you disagree with still needs code, test, docs, or requirement evidence before you dismiss it. A finding produced by `my-review` is not automatically correct; it can be wrong about intent, miss context the plan established, or misread a deliberate trade-off. This is exactly what `references/workflow-ledger-context.md` exists to catch — read the ledger's spec/plan before triaging, don't rely on whatever plan context happens to still be in the conversation, since this mode is also invoked standalone outside `my-workflow`'s loop. Record the disagreement and its evidence in the triage output rather than silently skipping the item.

## Commits in both modes

Each validated fix lands as its own local commit via the `commit` skill, scoped to that fix's files. A fix that fails validation stays uncommitted.

In PR mode, pushing, publishing replies, resolving threads, and re-requesting review all run automatically after the Step 2 triage confirmation — no further gate. In local mode there is no PR, so none of those four ever apply.

## Ledger append in both modes

Whenever the branch has a `my-workflow` ledger, the run ends by appending its round record (Step 13, `references/workflow-ledger-context.md`). The mode only changes what the record says: PR mode names the reviewer and PR number and reports what was pushed/replied/resolved; local mode names the fix-loop iteration and reports resolution per finding. Append-only in both — never rewrite an existing section, and never create a ledger that isn't there.
