## Cross-Artifact Analysis Report

### Artifacts Analyzed
| # | Type | Path | Date | Status |
|---|------|------|------|--------|
| 1 | Spec | ... | ... | ... |
| 2 | Research | ... | ... | ... |
| 3 | Plan | ... | ... | ... |

### Contradictions
Items where artifacts directly disagree.

1. **[Short title]**
   - [Artifact A] says: [quote/reference]
   - [Artifact B] says: [quote/reference]
   - Impact: [what goes wrong if unresolved]
   - Suggested resolution: [which artifact should win and why]

### Coverage Gaps
Requirements or findings with no downstream coverage.

1. **[Short title]**
   - Source: [Artifact] — [section/requirement]
   - Missing from: [which artifact(s) should cover this but don't]
   - Risk: [what happens if this stays uncovered]

### Scope Drift
Plan does more or less than spec asks.

1. **[Short title]**
   - Spec says: [reference]
   - Plan does: [reference]
   - Assessment: [intentional evolution or accidental drift?]

### Assumption Divergence
Artifacts assume different things.

1. **[Short title]**
   - [Artifact A] assumes: [X]
   - [Artifact B] assumes: [Y]
   - Reality (from code): [what's actually true, if verifiable]

### Staleness Risks
Findings that may no longer hold.

- [finding] from [research doc] — may be invalidated by [plan phase] which modifies [component]

### Requirements Traceability

| Spec Requirement | Research Basis | Plan Phase | Success Criterion |
|-----------------|----------------|------------|-------------------|
| Req 1: ... | Research finding X | Phase 2 | `command` |
| Req 2: ... | — | **MISSING** | — |
| Req 3: ... | Research finding Y | Phase 1 | **MISSING** |

### Overall Assessment
[1-2 sentences: are these artifacts aligned enough to proceed, or do contradictions/gaps need resolution first?]

### Recommended Actions
1. [Most important thing to resolve, with suggested owner: spec author, plan author, or researcher]
2. ...
```
