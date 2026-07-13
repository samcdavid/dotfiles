## Step 3 — Ambiguity Analysis

Work through the document systematically. For each section, ask:

### For Specs

**Requirements clarity**
- Can each requirement be tested with a binary yes/no? If not, it's underspecified.
- Are there requirements that use weasel words? ("appropriate", "graceful", "fast", "secure", "properly", "handle errors", "as needed")
- Do any requirements contradict each other?

**Boundary gaps**
- Are there inputs, user types, or scenarios not covered by any requirement?
- Does the "Excluded" section explain WHY each exclusion was made? (Unexplained exclusions often hide deferred decisions.)
- Are there implicit requirements that "everyone knows" but nobody wrote down?

**Dependency assumptions**
- Does this spec assume something exists that might not? (An API, a database table, a feature, a service)
- Does it assume a specific ordering of work?
- Are there external dependencies with no fallback plan?

**Edge cases**
- What happens at zero? At one? At maximum?
- What happens when the user does something unexpected?
- What happens when an external dependency fails?

**Success criteria gaps**
- Can success be verified by someone who didn't write the spec?
- Are there outcomes the spec cares about but doesn't measure?

### For Research Documents

**Completeness**
- Does the research fully answer the original question?
- Are there areas explicitly marked as open questions vs. areas that are simply missing?
- Were all relevant parts of the codebase examined, or just the obvious ones?

**Confidence levels**
- Are findings stated with appropriate certainty? ("X works this way" vs. "X appears to work this way based on [evidence]")
- Are there findings based on a single code path that might behave differently elsewhere?
- Are there conclusions drawn from outdated code or comments that might not reflect current behavior?

**Gaps in the evidence chain**
- Are there architectural claims without file:line references?
- Are there behavior claims that were inferred but not traced end-to-end?
- Are there patterns described as universal that were only observed in one location?

**Cross-reference gaps**
- Does the research consider how the investigated component interacts with its neighbors?
- Are there data flow paths that were only partially traced?
