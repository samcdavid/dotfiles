# Mode Routing

Load this when `my-review` needs help deciding review source of truth.

- `capture` or `promote`: use the learned-miss maintenance path; do not review code.
- PR number or URL: PR mode. Source of truth is `gh pr diff`, PR metadata, PR HEAD file fetches, and existing review threads.
- Branch name/range: compare against that base locally.
- Empty or `local`: review working tree changes with unstaged, staged, and relevant recent commits.

Before fan-out, produce a short triage block: intent, active lenses, requirements source, tracer triggers, author calibration when PR mode, and pending learned misses.

