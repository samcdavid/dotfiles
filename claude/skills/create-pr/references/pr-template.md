# PR Description Template

This is the output structure for `/create-pr`. Render this template with values from Step 3, save to a tempfile, and pass to `gh pr create --body-file` or `gh pr edit --body-file`.

The fenced block below is the literal body Markdown — copy its structure when composing.

````markdown
## Summary

<1 paragraph: what changed and why. Reviewers can dig into commits for detail.>

- <Up to 5 bullets on the key changes>

## Linked Ticket

<Linear URL, "Closes #N" line, or "none">

## Review Guidance

### Recommended Review Lens

- **Primary:** <Backend | Frontend | Full-stack | Quality | Security | Architect | PM | Ops> — run `/my-review <persona>`
- **Secondary:** <only when both halves of the PR have non-trivial work in different lenses>

### Triggered Specialty Reviews

Include only the triggered ones. Omit this subsection entirely if nothing triggered.

- **Security:** <one-line reason + affected files> — run `/security-review`
- **Architecture:** <one-line reason + affected files> — run `/my-arch-review`
- **Performance / Migration:** <one-line reason + affected files> — run `/perf-review`
- **LLM Eval Coverage:** <one-line reason> — verify the prompt/tool-docstring change has eval coverage before merge

### Focus Areas for Reviewers

Up to 5 specific places to look closely. Each entry is `path:line` + one-line "why."

- `path/to/file.ext:LINE` — <what to verify or scrutinize>

### Documentation Alignment

Include only when integration points (APIs, schemas, webhooks, public interfaces, env vars, CLI flags) changed. Omit otherwise.

- <Which docs/consumers need to be updated and confirmed>

## QA Instructions

How to verify locally. Tailor to the change:

- **Frontend:** user-facing steps to exercise the changed UI
- **Backend / API:** curl / GraphQL query / SQL with expected output
- **Bug fix:** reproduction on the base branch, then verification that the fix resolves it
- **Always:** the success criterion — what does "it works" look like?

## Risk Assessment

Only for **major** changes (see `review-categories.md`). Omit the whole section for minor changes.

- **Risk level:** Low / Medium / High
- **Rollback plan:** how to back this out if something goes wrong
- **Recovery time estimate:** minutes / hours
- **Monitoring:** what the on-call should watch during/after deploy
````

## Authoring Notes

- Keep the **Summary** terse — one paragraph and ≤5 bullets. Reviewers can read commits for the rest.
- The **Review Guidance** subsections are the value-add. Don't pad them; don't omit them either.
- **Triggered Specialty Reviews** entries should be sharp enough that a reviewer reading only that line knows what to look at.
- **Focus Areas** beat full coverage: three sharp entries are better than five vague ones.
- **Documentation Alignment** is opt-in by signal. If no integration points moved, omit it — empty doc sections train reviewers to skim past.
- **Risk Assessment** is gated by the major/minor verdict from the rubric. Don't sprinkle it onto minor PRs to feel complete.
