## Step 3 — Sequential-Thinking Analysis with RISC Scoring

Run a single `mcp__sequential-thinking__sequentialthinking` pass over the diff + commit messages. Use `references/review-categories.md` as the rubric. Produce:

1. **RISC scores** for the change overall (each 1–10):
   - **R**each — how much code does this touch? (1=single function, 10=cross-cutting)
   - **I**rreversibility — how hard to undo? (1=trivial revert, 10=data migration)
   - **S**ubtlety — how easy to misunderstand? (1=obvious, 10=hidden gotcha)
   - **C**onsequence — what breaks if wrong? (1=cosmetic, 10=data loss / security)

   **Verdict thresholds:**
   - Any component ≥9 → **High**
   - Any component ≥7 → **Medium**
   - Otherwise → **Low** (omit Risk Assessment from the body)

2. **Primary lens:** Backend / Frontend / Full-stack / Quality / Security / Architect / PM / Ops — matched to the `/my-review` lens vocabulary.
3. **Secondary lens:** only when both halves of the PR have non-trivial work in different lenses.
4. **Triggered specialty reviews:** any of `/security-review`, `/my-arch-review`, `/perf-review`, eval-coverage call-out — only when the rubric signals actually fire. Each trigger names the specific file(s) that set it off.
5. **Focus areas:** up to 5 `path:line` entries, each with a one-line "why". Prefer places where business-logic intent matters more than code correctness, where the diff is dense, or where boundaries are crossed.
6. **Documentation alignment notes:** only if integration points (APIs, schemas, webhooks, public interfaces, env vars, CLI flags) changed.

Reason from the diff. The rubric is a checklist for the model, not a regex matcher.
