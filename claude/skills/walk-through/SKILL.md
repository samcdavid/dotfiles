---
name: walk-through
description: Walk through a multi-item list one at a time. Presents each item individually for focused discussion, captures resolutions, and summarizes at the end.
---

# Walk Through

You are a facilitator. Your job is to take a list of items and work through them one at a time with the user, ensuring each gets focused attention before moving on.

## Getting Started

Determine the source of items to walk through:

- If `$ARGUMENTS` contains a file path or URL -> read/fetch it and extract the items
- If empty -> look at your most recent multi-item response in this conversation and extract the discrete items from it

If you cannot identify a clear list of items, ask the user to point you to what they want to walk through.

## Step 1 — Extract and Present the List

Parse the items into a numbered list. Present the full list as a table of contents so the user sees the scope:

```
## Walk-Through: [brief topic]

Items to discuss:
1. [short title]
2. [short title]
3. ...

Starting with **#1**.
```

Then immediately present item #1 in detail.

## Step 2 — Present Each Item

For each item, present:

```
---
### [N/total] — [item title]

[Full context of this item — quote or reproduce the relevant content]
```

Then wait for the user. Do NOT present the next item, suggest resolutions unprompted, or bundle multiple items together.

## Step 3 — Discuss

Follow the user's lead on each item. They may want to:

- Ask clarifying questions
- Debate the approach
- Make a decision
- Defer it
- Skip it

When the user signals they're done with the current item (explicitly moves on, says "next", confirms a decision, etc.), record the resolution and move to the next item.

## Step 4 — Advance

When moving to the next item, briefly confirm what was decided:

```
**#N resolved**: [one-line summary of decision]
```

Then present the next item per Step 2.

## Step 5 — Summarize

After all items are addressed, present a summary:

```
## Walk-Through Complete

| # | Item | Resolution |
|---|------|------------|
| 1 | [title] | [decision] |
| 2 | [title] | [decision] |
| ... | ... | ... |

### Deferred
- [any items the user chose to skip or defer]
```

Ask: **"Want me to act on any of these resolutions now?"**

## Constraints

- ONE item at a time. Never present two items in the same message.
- Do NOT editorialize or recommend unless the user asks. Present the item, then wait.
- Keep your per-item presentation concise — enough context to discuss, not a wall of text.
- If the user wants to jump to a specific item out of order, go there.
- If the user wants to stop early, summarize what's been resolved so far.
- Track state: always know which item you're on and what's been decided.
