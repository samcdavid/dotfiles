---
name: my-next
description: Synthesize the current session state into a clear, prioritized action plan. Use after prove-it, after a research or investigation phase, or whenever the conversation has diverged enough that the path forward is unclear.
disable-model-invocation: true
---

# What's Next

Synthesize the current state of the conversation into a clear course of action. Don't summarize the past — produce the plan forward.

## Step 1 — Orient

Review the full conversation and extract:

1. **The goal** — what was the original task or question?
2. **What's done** — work completed, changes made, findings confirmed
3. **What's broken** — retractions, corrections, or failures from prove-it or validate output
4. **What's unresolved** — open questions, unverified assumptions, blocked items, deferred decisions

If a prove-it report is present in the conversation, treat its sections as authoritative:
- **Retracted** claims → must be corrected before proceeding
- **Still Unverified** items → blockers if the next action depends on them; background tasks if they don't
- **Verified Facts** → confirmed foundation to build on

## Step 2 — Identify Blockers

A blocker is anything that, if wrong or unresolved, would cause the next action to be wasted effort or produce incorrect results.

For each blocker:
- State what's unknown or broken
- State the specific check or action needed to unblock it
- State whether it can be resolved immediately (read a file, run a command) or requires human input

Resolve immediately-resolvable blockers now — don't list them and move on.

## Step 3 — Produce the Action Plan

Output a prioritized list. Be opinionated: say what to do, not just what the options are. If there's a clear best next step, lead with it. Reserve options/tradeoffs for cases where human judgment is genuinely required.

```markdown
## Course of Action

### Immediate Next Step
[Single, concrete action — what to do right now and why it comes first]

### Then
1. [Next action, with enough context to act on it without re-reading the conversation]
2. [...]
3. [...]

### Blocked On (resolve before proceeding)
- [Item] — needs: [specific check or human decision]

### Deferred (don't do now)
- [Item] — why it's not the right time: [reason]
```

## Guidelines

- Lead with the action, not the analysis. The user can re-read the conversation for context.
- One immediate next step — not a list of equals. Force a priority.
- If prove-it surfaced a retraction that changes the approach, say so explicitly before the action plan.
- Don't restate what was already decided and executed. Start from the current edge.
- If the goal itself has shifted during the conversation, note that and confirm before proceeding.
