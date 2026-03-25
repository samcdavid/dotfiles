# Gotchas — my-plan

Known failure patterns and lessons learned. Read before starting work with this skill.

### Cross-layer completeness
- **Category:** failure-mode
- **Context:** Planning a fix or feature that touches backend logic
- **Wrong:** Plan addresses only the backend layer where the bug/feature lives
- **Right:** Trace the change through all layers (API → frontend → E2E) and explicitly scope-in or scope-out each layer in the plan
- **Why:** Plans that fix backend logic often miss required UI changes, leading to incomplete implementations that pass backend tests but break the user experience
- **Source:** Recurring pattern in PR reviews

### Cross-service contract alignment
- **Category:** failure-mode
- **Context:** Multiple services handle the same data structure
- **Wrong:** Plan assumes all services agree on data shape without verifying
- **Right:** Verify the contract is identical in all services that touch the data. Check for structural divergence (nested vs flat, field-level vs parent-level storage, nullable vs required)
- **Why:** Structural divergence between services causes subtle bugs that don't surface until integration testing or production
- **Source:** Recurring pattern in polyglot monorepo PRs

### Spec coverage validation
- **Category:** failure-mode
- **Context:** Finalizing a plan for a ticket or spec
- **Wrong:** Plan covers the obvious parts of the spec but misses edge requirements
- **Right:** Before finalizing, enumerate each requirement from the spec/ticket and confirm each has a corresponding phase or is explicitly scoped out with rationale
- **Why:** Partial spec completion is a recurring review finding — plans that seem complete but miss 1-2 acceptance criteria
- **Source:** Recurring pattern in PR reviews

### Boy scout rule — don't defer adjacent fixes
- **Category:** convention
- **Context:** Discovering inconsistencies, missing instrumentation, or small bugs in files you're already touching
- **Wrong:** Listing adjacent fixes in "What We're NOT Doing" or deferring to follow-up tickets. Example: finding an inconsistent tag name while adding tracing to the same module, and scoping it out as "not this ticket"
- **Right:** If you find something wrong or inconsistent in code you're already working in, bring it into scope. Only defer things genuinely unrelated to the current files and task. Challenge every item in the "NOT Doing" list — if it's in the same files or directly related, it belongs in the plan.
- **Why:** Deferring small fixes creates tech debt that never gets prioritized. The context is freshest now, and the cost of fixing it is lowest when you're already in the code.
- **Source:** Recurring pattern — adjacent improvements incorrectly scoped out during planning

### Plans and tickets are not verified facts
- **Category:** failure-mode
- **Context:** When a plan references another ticket's work as already done, or when scoping out changes based on reasoning about what another component does
- **Wrong:** Treating plan checkboxes, ticket descriptions, or your own prior claims as ground truth. Example: a plan states "ticket X establishes logging in the dispatcher" — stated confidently because the plan said it was done — but the dispatcher had zero logging code. Similarly, scoping out a function because "it accepts dot notation" sounded right but the actual code lacked the validation that reasoning implied.
- **Right:** Before referencing another ticket's infrastructure or excluding something from scope, read the actual code. A plan saying `[x]` doesn't mean the code exists. A tool "accepting" a parameter doesn't mean it enforces coherence. Verify the mechanism, not just the interface.
- **Why:** Plans describe intent, not state. Code in other branches may not be merged. Claims compound — one unverified assumption becomes the basis for the next conclusion, and by the time you fact-check, multiple decisions are built on sand.
- **Source:** Recurring pattern — plans referencing infrastructure from other tickets that didn't exist yet, and scoping decisions based on surface-level reasoning about code behavior
