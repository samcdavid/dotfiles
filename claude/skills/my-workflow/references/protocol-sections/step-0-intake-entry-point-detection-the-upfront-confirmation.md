## Step 0 - Intake & Entry-Point Detection

This first human touchpoint frames the workflow and creates or updates the ledger.

1. **Establish task.** Parse `$ARGUMENTS`:
   - Linear issue ID/URL -> fetch issue, comments, linked issues, project.
   - File path -> read fully.
   - URL -> fetch/extract.
   - Free-text description -> use task.
   - Empty -> read conversation context first; ask only if there is genuinely no target.
2. **Detect the workflow ledger first.** Search workflow ledgers under `~/.claude/thoughts/shared/workflows/`. Then search research, specs, and plans only to attach artifact paths to ledger stages. Artifacts do not mark stages complete by themselves.
3. **Choose full pipeline or quick handoff.** Use `references/stage-routing.md`. If no ledger exists and the work is not explicitly routed to `my-quick`, the entry stage is always `my-research`.
   - If routing to `my-quick`, open the workflow ledger first and record `route: my-quick`, reason, expected scope, skipped full-pipeline rationale, and exact handoff command.
   - Then present the handoff upfront instead of pretending the full pipeline started.
4. **Confirm mode once.** Present:

```markdown
Here's the task as I understand it: **[one paragraph]**.
Entry point: **[stage]**; skipped stages: **[only stages already completed in the ledger, with artifact paths]**.
Route: **[full pipeline | my-quick, with ledgered reason]**.

Mode: I run one stage at a time, checkpoint after each artifact, and give you an exact resume command. You can clear context between stages. The only uninterrupted block is `my-implement -> my-validate -> my-review`, and it is available only after the ledger marks research, spec, clarify, plan, observe, and analyze complete. Factual questions are researched; decisions stay yours. No commits/PRs/outward actions unless explicitly requested.

Starting assumptions: **[list]**.
```

Wait for go-ahead once to start the selected stage.

5. **Open ledger.** Create/update `~/.claude/thoughts/shared/workflows/<slug>.md` with task, base branch, chosen entry point, route, stage statuses, artifact paths, decisions, and autonomous assumptions. New full-pipeline ledgers start with all stages incomplete. Quick-handoff ledgers record the route and handoff command instead of stage completion. Update it at every checkpoint.
