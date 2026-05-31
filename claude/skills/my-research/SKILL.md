---
name: my-research
description: Deep codebase research with verified findings. Spawns parallel agents to explore, then cross-references all claims before presenting results. Use when you need to understand how something works before making changes.
---

# Research Codebase

Conduct comprehensive, VERIFIED codebase research. Every finding must be substantiated by code you actually read.

## Getting Started

Respond: "Ready to research. What's your question or topic?"

Wait for the user's research query before proceeding.

## Step 1 — Read Explicit Context

If the user mentions specific files, read them FULLY first (no limit/offset). This grounds your understanding before broader exploration.

## Step 2 — Decompose the Research Question

Break the question into composable research areas. For each area, identify:
- What files/components are likely involved
- What questions need answering
- What would constitute a COMPLETE answer

## Step 3 — Parallel Discovery

Spawn parallel sub-agent tasks to explore the codebase:
- **codebase-locator**: Find all relevant files and directories
- **codebase-analyzer**: Deep-read key implementations
- **codebase-pattern-finder**: Find related patterns and conventions

If the research touches **Datadog logs/spans** or **Braintrust project logs**, see `gotchas.md` first — attribute-prefixed queries (`@session_id:...`) for Datadog and a `list_recent_objects` discovery step for Braintrust are non-obvious requirements that cause silent 0-result returns or access errors otherwise.

### Available but situational: `requirements-tracer`

The **requirements-tracer** agent is available for spawning here, but is NOT a default. Spawn it ONLY when the research question is explicitly about **change impact or regression risk** — for example:

- "If I change `function_X`, what shipped features depend on it?"
- "What would break if we deprecated this endpoint?"
- "Which Linear issues touch the same code as ENG-1234?"

Do NOT spawn it for general "how does X work" questions. Research is question-driven, not change-driven — the tracer's blast-radius mapping produces noise when there's no change to evaluate.

When spawning, pass `mode: plan` (no diff exists during research), `scope: tight | medium | wide` based on how broad the user's impact question is, and either a Linear issue ID or an `intended_surfaces` list derived from the question.

Wait for ALL sub-agents to complete before proceeding.

## Step 4 — Synthesize Findings

Combine sub-agent results into a coherent picture. Resolve any contradictions — if agents report conflicting information, investigate until resolved.

Before declaring research complete, verify the **"Don't stop at external context"** gotcha doesn't apply: if the ticket/spec/research brief named open questions or "verify against code" references, those must be resolved here — not handed back to the user as "remaining research." External context (Linear, Notion) is the starting point, not the deliverable.

## Step 5 — Adversarial Challenge (MANDATORY)

Before finalizing, spawn the **adversarial-debate** agent to challenge your findings.

Format your detailed findings as structured claims and pass them to the agent along with:
- The file paths and code references supporting each finding
- Any architectural claims or interpretations
- The original research question

The agent will:
- Verify every file path and code snippet against current code
- Challenge interpretations — "you found X calls Y, but does that mean what you think it means?"
- Check for contradictions between findings
- Steel-man alternative interpretations of the code
- Flag conclusions that go beyond what the evidence supports

Apply the agent's verdicts:
- **KEEP**: finding is well-grounded, present as-is
- **REVISE**: adjust the claim to match what the evidence actually shows
- **DROP**: remove findings that couldn't be verified or were based on misread code

After applying verdicts, confirm:
- [ ] The research question is fully addressed
- [ ] Open questions are explicitly noted (not silently skipped)
- [ ] No contradictory findings remain unresolved

Do NOT present unverified claims.

## Step 6 — Save Research Document

Save to `~/.claude/thoughts/shared/research/NNN_topic.md` using 3-digit sequential numbering.

Format:
```markdown
---
date: [ISO timestamp]
topic: [Research topic]
tags: [relevant, tags]
status: complete
---

# Research: [Topic]

## Research Question
[The original question]

## Summary
[2-3 paragraph executive summary]

## Detailed Findings

### [Component/Area 1]
[Findings with file:line references]

### [Component/Area 2]
...

## Architecture Insights
[How components relate, data flow, key boundaries]

## Code References
[Index of all files examined]

## Open Questions
[Anything that remains unclear — be explicit]
```

Present the summary to the user and provide the file path.

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.
