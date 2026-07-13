## Step 5 — Compose the Description

Render `references/pr-template.md`, filling each section from Steps 3 and 4.

The template is **two-level by design**: every section is a terse scannable top half (one-phrase bullets, lens names, paths) plus a collapsed `<details>` block carrying the deeper rationale. When composing:

- **Summary top half:** 1–2 sentences of plain language. Frame from a user-visible angle. No file paths, no module names, no implementation detail — those go inside the `What changed` details block.
- **Review Guidance top half:** two lines — `Lens: …` and `Triggered specialty reviews: …`. Names only, comma-separated. Rationale goes in the details block.
- **Focus Areas top half:** `path:line` + one-phrase what to verify. The longer "why this matters" goes in the details block.
- **QA Instructions:** user-facing actions only — clicks, URLs, curl calls, MCP tool invocations, reproduction steps. **Never** include `mix test`, `pytest`, `npm test`, lint, or build commands. CI runs those.

The **Review Guidance** section is required on every PR. The **Risk Assessment** block renders only when the RISC verdict is **Medium** or **High**. The **Where I'm Uncertain** section renders only when Step 4 produced entries.

Title:
- Inspired by branch name + commit subjects
- Conventional-commit prefix (`fix:`, `feat:`, `refactor:`, `chore:`, etc.) when it fits
- If `.github/PULL_REQUEST_TEMPLATE.md` or a `pr_*_check` workflow exists, read it and honor any required title pattern (e.g. ticket suffix)
- Otherwise plain title

Save the rendered body to a tempfile (`mktemp`) so `gh` can read it via `--body-file`.
