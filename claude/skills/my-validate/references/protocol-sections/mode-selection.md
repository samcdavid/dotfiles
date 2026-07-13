## Mode Selection

- If `$ARGUMENTS` contains a path to a plan file, use **Plan Mode**.
- If `$ARGUMENTS` is `session` or empty and there is no plan context, use **Session Mode**.
- If ambiguous, ask the user which mode they want.

Regardless of mode: after identifying the active plan (from `$ARGUMENTS` or session context), check for a companion observability plan. Look in `~/.claude/thoughts/shared/plans/` for a file matching `*a_*observability*` whose `parent_plan` frontmatter points to the active plan. If found, run **Observability Validation** as an additional phase appended to the normal validation report.

---
