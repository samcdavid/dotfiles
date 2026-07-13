## Step 3 — Plan Structure

Propose a phasing structure:
- How many phases
- What each phase accomplishes
- Dependencies between phases
- What's explicitly OUT OF SCOPE

### Phase Sizing — one function at a time (HARD RULE)

Each phase is the smallest unit you'd implement and test in isolation before looking back at the checklist — **typically a single function, method, or one narrow behavior.** Plan the way you'd code by hand: write a test for one function, implement that one function, verify it, then return to the plan for the next. A phase is the right size when:

- It touches **a small, bounded set of files** (ideally one production file + its test).
- It encodes **one behavioral expectation** — one RED test (or a tight cluster) and the minimum GREEN code to satisfy it.
- An implementer who sees **only that phase** — not the whole plan, not the whole repo — could complete it without broad cross-cutting reading. (`my-implement` dispatches each phase to an isolated subagent with a small context budget; an oversized phase blows that budget and gets bounced back for splitting.)

If a unit of work would require touching many files, holding lots of repo context, or bundling several behaviors, **split it into multiple phases.** More small phases is better than fewer large ones — the checklist is meant to be long and granular. Order phases so each depends only on earlier ones (they run sequentially).

Every phase runs the same three subphases: **RED** (write the failing test), **GREEN** (minimum code to pass), **VALIDATE** (run the phase's mechanical success criteria). Plan all three for each phase.

If the **requirements-tracer** ran in Step 1 and surfaced `At-risk` related issues, factor them in:
- Related-issue regression risks shape the `What We're NOT Doing` boundary (e.g., "do NOT alter the return shape of `X` — issue ENG-1234 depends on the current shape").
- Each `At-risk` finding becomes a candidate entry in the relevant phase's `What Could Go Wrong` section.
- Surfaces the tracer flagged as having thin test coverage become candidate entries in the phase's `Tests First (RED)` list — write regression tests for the existing behavior before changing the surface.

Confirm alignment before writing the full plan.
