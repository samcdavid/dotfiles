# Protocol — skill-my-research

Full private procedure for the `skill-my-research` runner. The `my-research` wrapper normalizes request context, preserves the user-facing boundary, and presents the compact result. Retained standalone gotchas live at `~/.claude/skills/my-research/gotchas.md`, or `~/.agents/skills/my-research/gotchas.md` under Codex.

## Research Codebase

Conduct comprehensive, VERIFIED codebase research. Every finding must be substantiated by code you actually read.

## Workflow Ledger (read first)

This skill runs both standalone and as a stage inside `/my-workflow`. Before anything else, look for the issue's workflow ledger:

- Search `~/.claude/thoughts/shared/workflows/` for a ledger matching this task (by Linear ID, ticket slug, or topic).
- **If one exists, read it fully.** It is the plan-of-record for the whole issue: the task framing, which stages have run, the artifacts they produced (with paths), and the running "Autonomous decisions & assumptions" list. Treat it as authoritative shared context — never re-ask or re-derive what it already settles, and prefer its artifact paths over re-discovering them.
- **When you finish, if a ledger exists, append this stage's outcome to it only in standalone mode**: the research doc path and any assumptions/decisions recorded here. In embedded mode, return that data in the output envelope so `my-workflow` records it itself.
- If no ledger exists, proceed without one — do not create a workflow ledger yourself (that is `/my-workflow`'s job).

## Getting Started

Determine the research question without a blank prompt:
- If `$ARGUMENTS` names a question, topic, ticket, or file → use it.
- If empty → read the conversation context and the workflow ledger first, identify the most likely subject, and open with a concrete proposal ("Based on [X], I'll research [question] — is that right?").
- Only fall back to "Ready to research. What's your question or topic?" when there is genuinely nothing to go on.

## Step 1 — Read Explicit Context

If the user mentions specific files, read them FULLY first (no limit/offset). This grounds your understanding before broader exploration.

## Step 2 — Decompose the Research Question

Break the question into composable research areas. For each area, identify:
- What files/components are likely involved
- What questions need answering
- What would constitute a COMPLETE answer

## Step 3 — Parallel Discovery

Research every source before concluding anything is unknown — always answer your own question first. Spawn in parallel where possible:

- **Codebase** — `codebase-locator` (find all relevant files/directories), `codebase-analyzer` (deep-read key implementations), `codebase-pattern-finder` (related patterns and conventions).
- **Linear** — the linked issue, its comments, linked issues, and project, for product intent and prior decisions.
- **Notion** — `notion-search` / `notion-query-data-sources` for design docs, RFCs, PRDs, and meeting notes.
- **Google Drive** — prefer an installed, authenticated `gws` CLI (`gws drive files list` to search, `gws docs documents get` for Google Docs, or `gws drive files get` with `alt=media` and `--output` for non-Docs; consult `gws schema` for request shape). Fall back to `Google_Drive__search_files` + `read_file_content` / `download_file_content` only when `gws` is absent, unauthenticated, lacks the required capability, or still fails after correcting the request once. Do not initiate interactive CLI auth or export credentials.
- **Thoughts artifacts** — adjacent research/specs/plans in `~/.claude/thoughts/shared/` and the issue's workflow ledger.

External context (Linear/Notion/Drive) is the starting point for the question, not a substitute for reading code — per the **"Don't stop at external context"** gotcha, every open question or "verify against code" reference it surfaces must be chased into the codebase, not handed back.

If the research touches **Datadog logs/spans** or **Braintrust project logs**, read `~/.claude/skills/my-research/gotchas.md` (or `~/.agents/skills/my-research/gotchas.md` under Codex) first — attribute-prefixed queries (`@session_id:...`) for Datadog and a `list_recent_objects` discovery step for Braintrust are non-obvious requirements that cause silent 0-result returns or access errors otherwise.

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

Present the summary to the user and provide the file path. In standalone mode, append the research doc path and any logged assumptions to an existing workflow ledger. In embedded mode, return them in the output envelope for `my-workflow` to record.

## Output Envelope

Return a compact result, never raw tool or subagent transcripts:

```markdown
status: complete | needs_input | blocked
artifact: { kind: research, path: <path> }
summary: <verified findings only>
assumptions: [<factual assumption>]
provisional_decisions: []
open_questions: [<remaining uncertainty>]
external_action_requested: null | { actions, targets, rationale }
```

In embedded workflow mode, return unresolved uncertainty and any decision that cannot be settled from evidence in `provisional_decisions` with a recommendation; do not interrupt the stage for user input. The coordinator updates the ledger from this envelope. Standalone runs may return `needs_input` only when the research subject is genuinely indeterminate.

## Gotchas

Read `~/.claude/skills/my-research/gotchas.md` (or `~/.agents/skills/my-research/gotchas.md` under Codex) before starting work. These are known failure patterns — avoid them.
