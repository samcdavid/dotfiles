# PR Body Template

Every section is two-level: a terse top half a reviewer scans, and a collapsed `<details>` block for depth. If a reviewer has to expand a block to learn what the PR is about, the top half is wrong. Omit any section marked optional when it doesn't apply.

````markdown
## Summary

<1–2 plain-language sentences, user-visible angle. No file lists or internals.>

<details>
<summary><b>What changed</b></summary>

- <up to 5 bullets; paths and internals are fine here>

</details>

<details>
<summary><b>Resources</b></summary>

- Linear: <ticket URL>
- <Figma, Loom, Datadog, related PRs found in commits/diff>

</details>
<!-- optional: omit when nothing to link -->

<details>
<summary><b>Implementation decisions</b></summary>

- **<decision>:** <outcome> — <rationale/source>

<!-- always render; if no record: "No decision record was found for this branch; the diff is not enough to reconstruct why choices were made." -->
</details>

## Review Guidance

**Lens:** <Primary>[, <Secondary>]
**Triggered concerns:** <Security, Architecture, …>  <!-- omit line if none -->

<details>
<summary><b>Lens and trigger rationale</b></summary>

- **<Lens/concern>:** <one-line why + affected files>

</details>

## Focus Areas for Reviewers

- `path/to/file.ext:LINE` — <what to verify>

<details>
<summary><b>Why these focus areas matter</b></summary>

- `path/to/file.ext:LINE` — <the invariant, boundary, or business intent; which test proves it>

</details>

## Where I'm Uncertain
<!-- optional: only untested claims, max 3 -->

- <claim — where it lives — the test that would verify it>

## QA Instructions

<2–6 user-facing steps with expected results: click paths, API/MCP calls and response shape, repro steps, async trigger + where the side effect shows up. Never test/lint/build commands — CI runs those.>

<details>
<summary><b>Documentation Alignment</b></summary>
<!-- optional: only when APIs, schemas, webhooks, env vars, or CLI flags moved -->

- <docs/consumers to update>

</details>

<details>
<summary><b>Risk Assessment</b></summary>
<!-- optional: only for Medium/High RISC -->

- **Verdict:** Medium / High
- **Failure mode:** <what breaks>
- **Rollback plan:** <how to back out; data/migration notes>
- **Monitoring:** <what to watch after deploy>
- **RISC components ≥7:** <e.g. Subtlety=8 (sync/async timing coupling)>

</details>
````
