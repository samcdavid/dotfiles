# PR Description Template

This is the output structure for `/create-pr`. Render this template with values from Steps 3 and 4, save to a tempfile, and pass to `gh pr create --body-file` or `gh pr edit --body-file`.

## Design principle

Every section is **two-level**: a terse top half a reviewer can read at a glance, and a collapsed `<details>` block for the deep context. Bullets at the top half are one-phrase. The `<details>` block carries the implementation detail, file paths, rationale, and anything else a careful reviewer wants on demand.

The PR body is a scanning surface, not a design doc. If a reviewer has to expand `<details>` to see what the PR is about, the top half is doing the wrong job.

## Body Markdown

The fenced block below is the literal body Markdown — copy its structure when composing.

````markdown
## Summary

<1–2 sentences in plain language: what this PR adds or changes. Frame from a user-visible angle when possible. Don't restate the diff, don't list files, don't name internals.>

<details>
<summary><b>What changed</b></summary>

- <Up to 5 bullets on the key implementation moves>
- <File paths, modules, internals are fine here — this is the detail layer>

</details>

<details>
<summary><b>Resources</b></summary>

- Linear: <ticket URL, or "none">
- <Other relevant URLs from commits / diff: Figma, Loom, Datadog, related PRs, design docs>

</details>

<!-- Omit the entire Resources <details> block when no ticket is linked and no other resources are found. -->

## Review Guidance

**Lens:** <Primary>[, <Secondary>]
**Triggered specialty reviews:** <Security>, <Architecture>, <Performance>, <Ops>, <Eval coverage>

<!-- Triggered line: comma-separated names only; list only triggered. Omit the line entirely if nothing triggered. -->

<details>
<summary><b>Lens and trigger rationale</b></summary>

- **Primary lens — <Backend | Frontend | Full-stack | Quality | Security | Architect | PM | Ops>:** <one-line why> — run `/my-review <lens>`
- **Secondary lens — <…>:** <one-line why; omit subsection when none>
- **Security:** <one-line reason + affected files> — run `/security-review`
- **Architecture:** <one-line reason + affected files> — run `/my-arch-review`
- **Performance / Migration:** <one-line reason + affected files> — run `/perf-review`
- **LLM Eval Coverage:** <one-line reason> — verify eval coverage before merge

</details>

## Focus Areas for Reviewers

- `path/to/file.ext:LINE` — <one-phrase what to verify>
- `path/to/other.ext:LINE` — <one-phrase what to verify>

<details>
<summary><b>Why these focus areas matter</b></summary>

- `path/to/file.ext:LINE` — <fuller explanation: the subtle invariant, the boundary, the magic value, the business intent that matters more than code correctness, the test that proves or doesn't prove the claim>
- ...

</details>

## Where I'm Uncertain

<!-- Omit this section entirely when Step 4 found test coverage for every focus area. Cap at 3 entries. -->

- <The claim — where it lives — what test would have verified it>

## QA Instructions

<2–6 user-facing steps to exercise the change. Do NOT include test commands, lint commands, build commands, or CI checks — CI handles those. QA is about exercising the feature as a real user (or calling client) would.>

1. <Concrete step>
2. <Concrete step with expected observable result>
3. ...

<details>
<summary><b>Documentation Alignment</b></summary>

<!-- Omit this entire <details> block when no integration points moved. -->

- <Which docs/consumers need to be updated and confirmed>

</details>

<details>
<summary><b>Risk Assessment</b></summary>

<!-- Omit this entire <details> block when the RISC verdict is Low. -->

- **Verdict:** Medium / High
- **Failure mode:** <what specifically breaks if this goes wrong>
- **Why it's risky:** <1–2 sentences naming the specific concern>
- **Rollback plan:** <how to back this out — sha to revert, any data/migration notes>
- **Recovery time:** <immediate via revert / minutes via rollback / hours if data reconciliation needed>
- **Monitoring:** <what the on-call should watch during/after deploy>
- **RISC components ≥7:** Subtlety=8 (timing coupling between sync and async paths), Consequence=7 (data drift if retried)

</details>
````

## Authoring notes

- **Summary** is 1–2 sentences of plain language. Frame from a user-visible angle. The implementation tour goes inside the `What changed` details block, not in the Summary.
- **Resources** stays collapsed by default. Always include the Linear link when a ticket was detected; add other URLs only when they surfaced in commits or the diff. Omit the block when there's truly nothing to link.
- **Review Guidance** top half is two short lines — the lens names and the triggered-review names. Save the *why* for the details block.
- **Focus Areas** top half is paths + one-phrase whats. The deeper explanation (invariants, boundaries, test coverage) goes in the details.
- **Where I'm Uncertain** is a humility signal, not a confessional. Name the claim, where it lives, and the test that *would* have verified it. Omit the section when every focus area is grounded.
- **QA Instructions are user-facing.** No `mix test`, no `pytest`, no lint commands, no `bundle exec`. CI runs those. QA is: click-paths and observable UI changes; curl / MCP / API calls and the expected response shape; reproduction steps for bug fixes; trigger + side-effect-location for async work.
- **Documentation Alignment** and **Risk Assessment** live in collapsed `<details>` blocks at the very end of the PR body. They're deploy-time and follow-up context — not what a reviewer scans the body for. Omit either block entirely when it doesn't apply (no integration points moved, or RISC verdict is Low).
- **Risk Assessment** is gated by the RISC verdict. Render only when a component ≥7. Surface the specific component scores ≥7 in the body so the reviewer sees *which dimension* is risky.
- **Density gradient:** every section should read top-to-bottom from scannable → detailed. If a reviewer can't tell what to do from the top half alone, the top half is too dense or the details block is in the wrong place.
