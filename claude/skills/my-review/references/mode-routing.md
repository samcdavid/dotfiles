# Mode Routing

Load this when `my-review` needs help deciding review source of truth.

- `capture` or `promote`: use the learned-miss maintenance path; do not review code.
- PR number or URL: PR mode. Source of truth is `gh pr diff`, PR metadata, PR HEAD file fetches, and existing review threads.
- Branch name/range: local mode with that branch as the base instead of the detected default.
- Empty or `local`: review the **whole branch** — every commit since the merge base with the base branch, plus staged and unstaged changes. Source of truth is `git diff $(git merge-base origin/<base> HEAD)`. Bare `git diff`, `git diff --cached`, `git show HEAD`, and `git diff HEAD~1` are all wrong scopes: the first two go empty once the branch is committed, and the last two review a single commit out of many.

Before fan-out, produce a short triage block: resolved scope (base ref, commit count, file count), intent, active lenses, requirements source, tracer triggers, author calibration when PR mode, and pending learned misses.

