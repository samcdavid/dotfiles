## Guidelines

- **Do not fabricate.** Describe only what the diff shows. If you didn't read it, don't claim it. RISC scores must come from the actual change, not pattern-match against the diff size.
- **Two-level density.** Every section is a terse scannable top half plus a collapsed `<details>` block for the deep context. Top halves are one-phrase bullets or comma-separated names. File paths, internals, and rationale live inside `<details>`. If a reviewer has to expand `<details>` to know what the PR is about, the top half is doing the wrong job.
- **Summary is plain language.** 1–2 sentences. Frame from a user-visible angle. No file paths, no module names, no implementation detail in the Summary itself — those go inside the `What changed` details block.
- **QA Instructions are user-facing.** No `mix test` / `pytest` / `npm test`, no lint, no build commands — CI handles those. QA is click-paths and UI observations, curl / MCP / API calls and expected response shapes, reproduction steps for bug fixes, or trigger + observable side-effect for async work.
- The Review Guidance section is the point of this skill — don't skip it, even on Low-verdict PRs.
- Triggered specialty reviews must be **specific**: name the file(s) and the reason. "Auth might be affected" is not specific.
- Focus areas should be things a human is more likely to catch than a reviewer skill — UX edge cases, business-logic intent, unusual integrations, subtle invariants (idempotency, ordering, timing).
- **Where I'm Uncertain is honest, not exhaustive.** Only call out spots where a test would have verified your claim and didn't exist. Don't pad.
- **Risk Assessment surfaces RISC component scores in the body only when a component is ≥7.** Otherwise the verdict + failure mode + rollback is enough. Don't dump the full RISC table for a Low-verdict PR.
- Documentation alignment: only include when integration points actually changed. Don't pad.
- Don't write findings here that `/my-review` would catch. This skill routes review; it does not perform review.
- Title format: honor repo conventions if detectable, otherwise stay plain. Don't invent a convention.
- Never auto-create. The user approves first, every time.
