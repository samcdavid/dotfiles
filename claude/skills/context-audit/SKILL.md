---
name: context-audit
description: Audits context window usage and helps drop unnecessary content. Identifies what's consuming context, flags waste, and offers to compact or shed load. Use when performance degrades, responses feel shallow, or the session has been running long.
---

# Context Audit

Analyze what's consuming the context window in this session and help reclaim space.

## Step 1 — Inventory Context Load

Catalog everything currently loaded or referenced in the conversation:

| Category | Examples | Likely Size |
|----------|----------|-------------|
| **CLAUDE.md files** | Global, project, nested | Count them, estimate line counts |
| **Rules files** | `.claude/rules/*.md` | List any that loaded |
| **Skill definitions** | Current skill + any referenced | Note which loaded |
| **Files read** | Every file Read tool has returned | List with line counts |
| **Tool results** | Large command outputs, search results, web fetches | Estimate sizes |
| **Conversation turns** | Back-and-forth messages | Count and estimate |
| **MCP tool schemas** | Deferred tools loaded via ToolSearch | Count loaded tools |
| **System context** | System prompts, memory files | Estimate overhead |

Present this as a table sorted by estimated size (largest first).

## Step 2 — Identify Waste

Flag items that are consuming context without providing value:

- **Stale file reads** — files read early that are no longer relevant
- **Large tool outputs** — verbose command results that could have been filtered
- **Redundant reads** — same file read multiple times
- **Oversized MCP schemas** — tool definitions loaded but never used
- **Completed tangents** — entire conversation branches that are resolved and no longer needed
- **Duplicated context** — CLAUDE.md content that repeats across layers

## Step 3 — Recommend Actions

For each waste item, suggest a specific action:

| Action | How | Effect |
|--------|-----|--------|
| **Compact** | `/compact` with a focus prompt | Compresses conversation history, keeping key context |
| **Compact with focus** | `/compact [topic]` | Targeted compression — keeps only context relevant to the topic |
| **Start fresh** | New session with a handoff message | Nuclear option — write a handoff summary first |
| **Narrow scope** | Stop loading unnecessary files | Preventive — avoid reading files you won't need |

### Compaction Guidance

If recommending `/compact`, draft a focus prompt the user can use:

> "Compact this conversation, preserving: [list the 3-5 things that matter]. Drop everything related to: [list the resolved tangents and stale context]."

## Step 4 — User Choice

Present the recommendations and ask what the user wants to drop. Do NOT compact or take action without explicit confirmation.

If the user wants to drop specific context:
1. Suggest the most targeted `/compact` invocation that would shed that content
2. If the content is a resolved tangent, suggest compacting with a focus prompt that excludes it
3. If the session is beyond saving, draft a handoff message for a new session that captures only the essential state

## Constraints

- You cannot directly remove items from the context window — only `/compact` and starting a new session can reduce it
- Be honest about what compaction can and cannot do — it compresses, it doesn't surgically remove
- Don't recommend compaction if the session is short and context is healthy
- If the main problem is too many MCP tool schemas loaded, note that those persist even after compaction
