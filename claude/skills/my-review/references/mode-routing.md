# Mode Routing

Load this when `my-review` needs help deciding review source of truth.

- `capture` or `promote`: use the learned-miss maintenance path; do not review code.
- PR number or URL: PR mode. Source of truth is `gh pr diff`, PR metadata, PR HEAD file fetches, and existing review threads.
- Linear issue ID or URL: local issue mode. Use the issue as the primary requirements and project-context source, but keep the local branch-wide diff as the code source of truth.
- Branch name/range: local mode with that branch as the base instead of the detected default.
- Empty or `local`: review the **whole branch** — every commit since the merge base with the base branch, plus staged and unstaged changes. Source of truth is `git diff $(git merge-base origin/<base> HEAD)`. Bare `git diff`, `git diff --cached`, `git show HEAD`, and `git diff HEAD~1` are all wrong scopes: the first two go empty once the branch is committed, and the last two review a single commit out of many.

Before fan-out, produce a short triage block: resolved scope (base ref, commit count, file count), intent, active lenses, requirements source, tracer triggers, author calibration when PR mode, and pending learned misses.

Also resolve the verdict relationship:

- `local`: local, branch/range, local-issue, and embedded-local modes.
- `self_authored_pr`: PR author login equals the authenticated GitHub login.
- `third_party_pr`: PR author login differs from the authenticated GitHub login.
- `unknown_pr`: either login cannot be established.

Only `third_party_pr` is eligible for `COMMENT`. Every other relationship has a
binary verdict: `REQUEST_CHANGES` for a verified Critical, High-risk blocker;
otherwise `APPROVE`.
