## Step 0 — Set the Bar

Parse `$ARGUMENTS` for a bar level. Default is **strict**.

| Bar | What survives | What drops |
|-----|---------------|------------|
| **strict** (default) | Items that will cause a bug, lose data, create a vulnerability, break a contract, or compound if left in place. | Style, preference, nits, "could be cleaner", speculative perf, anything reversible cheaply later. |
| **moderate** | Above, plus clarity/maintainability items that materially help future readers or prevent foot-guns. | Pure style, formatting, naming preference, hypothetical perf without evidence. |
| **loose** | Above, plus anything that improves the code if cheap to apply. | Bikeshedding, redundant findings, items already covered by tooling. |

If `$ARGUMENTS` contains `strict`, `moderate`, or `loose`, use it. Otherwise default to **strict**.

State the bar back to the user in one line before proceeding.
