# PR Description Template

This is the output structure for `/create-pr`. Render this template with values from Steps 3 and 4, save to a tempfile, and pass to `gh pr create --body-file` or `gh pr edit --body-file`.

The fenced block below is the literal body Markdown — copy its structure when composing.

````markdown
## Summary

<1 paragraph: what changed and why. Reviewers can dig into commits for detail.>

- <Up to 5 bullets on the key changes>

<details>
<summary><b>Resources</b></summary>

- Linear: <ticket URL, or "none">
- <Other relevant URLs from commits / diff: Figma, Loom, Datadog, related PRs, design docs>

</details>

<!-- Omit the entire <details> block when no ticket is linked and no other resources are found. Omit individual lines for any missing resource. -->

## Review Guidance

### Recommended Review Lens

- **Primary:** <Backend | Frontend | Full-stack | Quality | Security | Architect | PM | Ops> — run `/my-review <lens>`
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

### Where I'm Uncertain

Omit this subsection entirely when Step 4 found test coverage for every focus area. Cap at 3 entries.

- I assumed <X> preserves <Y> semantics; no test in `<test-path>` covers this path.

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

Omit the entire section when the RISC verdict is **Low** (see `review-categories.md`).

- **Verdict:** Medium / High
- **Failure mode:** <what specifically breaks if this goes wrong>
- **Why it's risky:** <1–2 sentences naming the specific concern>
- **Rollback plan:** <how to back this out — sha to revert, any data/migration notes>
- **Recovery time:** <immediate via revert / minutes via rollback / hours if data reconciliation needed>
- **Monitoring:** <what the on-call should watch during/after deploy>
- **RISC components ≥7:** Subtlety=8 (timing coupling between sync and async paths), Consequence=7 (data drift if retried)
````

## Authoring Notes

- Keep the **Summary** terse — one paragraph and ≤5 bullets. Reviewers can read commits for the rest.
- **Resources** is collapsed by default so the body reads cleanly. Always include the Linear link when a ticket was detected; add other URLs only when they surfaced in commits or the diff.
- The **Review Guidance** subsections are the value-add. Don't pad them; don't omit them either.
- **Triggered Specialty Reviews** entries should be sharp enough that a reviewer reading only that line knows what to look at.
- **Focus Areas** beat full coverage: three sharp entries are better than five vague ones.
- **Where I'm Uncertain** is a humility signal, not a confessional. Name the claim, where it lives, and the test that *would* have verified it. Omit the section when every focus area is grounded.
- **Documentation Alignment** is opt-in by signal. If no integration points moved, omit it — empty doc sections train reviewers to skim past.
- **Risk Assessment** is gated by the RISC verdict. Render only when a component ≥7. Surface the specific component scores ≥7 in the body so the reviewer sees *which dimension* is risky.
