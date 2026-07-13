## Stage notes (where the override needs specifics)

- **2 `my-spec` / 3 `my-clarify`:** These are the most question-prone. Most "questions" are *factual* and answerable from research + code — resolve those and record assumptions. The residue is usually a genuine scope or product-intent **decision** (what's in scope, what success means, which trade-off) — surface those to the user rather than deciding for them. Feed clarify's resolutions back into the spec file before planning.
- **5 `my-observe`:** It asks which observability platforms/alert channels exist. Detect from the repo first (config files, dependencies, existing dashboards/monitors, CLAUDE.md). If undetectable, default to platform-agnostic recommendations rather than asking. Its output is a companion observability plan linked to the main plan — keep it as a deliverable, not a blocker.
- **7 `my-implement`:** The autonomous code-writing core. It orchestrates the plan one small phase at a time, dispatching each to an isolated `implementation-executor` that does red/green/validate TDD, then re-verifying the result itself. TDD is non-negotiable, and phases must be function-grained — if a plan phase is too big for a single executor, it gets split before dispatch. Honor the orchestrator's **loop detection**: if the same check fails 3× across attempts (executor + re-verify), STOP and escalate with the error output and your root-cause theory — that is a genuine blocker, not something to power through.
- **8 `my-validate`:** Run in **Plan Mode** against the plan file from stage 4. Let it self-repair trivial failures; escalate what it cannot fix confidently.
- **Compute the diff once for the review stage.** Detect the base branch and the changed files, then pass both to `my-review`:
  ```bash
  base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
  [ -z "$base" ] && { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }
  git diff --name-only "$base"...HEAD
  git diff "$base"...HEAD   # the review scope
  ```
- **9 `my-review`:** The single, consolidated review stage. Invoke it with the base branch name so it diffs the current work tree vs `main`/`master`; stay in read-only local review — no checkout, no PR. Because this is the deliberate full pipeline, don't let lens triage thin the review:
  - **Force the full lens set active** — Security, Architecture, Performance, QA, and PM/requirements, plus whichever general lenses (Backend/Frontend/Ops/Migration/Dependency) the diff touches. The pipeline always wants the comprehensive pass, not a minimal triage.
  - **Feed the stage-2 spec as the requirements source.** Pass the spec path so `requirements-reviewer` traces acceptance criteria against the spec (and any linked Linear ticket) — this replaces the former standalone `requirements-audit` stage and satisfies its "requires a spec" need without asking.
  - It internally spawns the research subagents + the per-lens reviewers, then merges, de-dupes, runs the adversarial pass, and proposes a verdict. That single output is the pipeline's complete review surface.
