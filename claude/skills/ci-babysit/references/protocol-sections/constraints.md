## Constraints

- **Always rerun from failure, not from start** — when rerunning a workflow (flaky tests, infra failures), always use `fromFailed: true`. Rerunning from start wastes time re-running jobs that already passed. Only rerun from start if explicitly asked or if the failure suggests earlier jobs produced bad artifacts.
- **Never stop monitoring until every job is green** — the whole point is that you babysit it to completion. Running jobs mean keep waiting. Failed jobs mean fix and retry. The only exits are: all green, user interrupts, or fix limit reached.
- **Never modify CI configuration** — `.circleci/config.yml` and pipeline config are off-limits. If the config is the problem, tell the user.
- **Never approve gates** — approval jobs require human judgment. Notify and wait.
- **Never force-push** — always add new commits on top.
- **Never skip hooks** — if a pre-commit hook fails on your fix, fix the hook issue too.
- **Minimal fixes only** — fix exactly what's failing. Don't refactor, don't improve, don't clean up. The goal is green CI, not better code.
- **Ask when stuck** — if you can't determine why something failed or how to fix it, present the failure to the user rather than guessing.
