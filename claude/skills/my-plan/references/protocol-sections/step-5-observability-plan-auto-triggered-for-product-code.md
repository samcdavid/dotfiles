## Step 5 — Observability Plan (Auto-triggered for product code)

After writing the plan, determine whether an observability plan is needed.

### When to include an observability plan

**YES — create an observability plan** if the changes touch:
- Production-facing code paths (API endpoints, request handlers, controllers)
- Background workers, job queues, or scheduled tasks
- Business logic (domain operations, data transformations, workflow steps)
- LLM agent calls, tool dispatch, or AI pipeline components
- Database operations (queries, migrations that change runtime behavior)
- External integrations (third-party APIs, webhooks, event consumers)
- Any code path a real user or system depends on in production

**NO — skip the observability plan** if the changes are limited to:
- Tests only (`test/`, `spec/`, `*_test.*`, `*.spec.*`)
- Dev tooling or scripts (CI config, Makefiles, shell scripts, seed scripts)
- Documentation or configuration files (no runtime behavior change)
- Dependency version bumps with no code changes
- Linting, formatting, or type annotation fixes
- Internal dev utilities not deployed to production

If the change is mixed (e.g. product code + tests), apply the product code rule — create the observability plan.

### When triggered

Run the `my-observe` skill, passing the current plan file path as context. Save the resulting observability plan to `~/.claude/thoughts/shared/plans/NNNa_{ticket}_observability.md` (same number as the main plan, with `a` suffix) and add `parent_plan: [path to main plan]` to its frontmatter.

---
