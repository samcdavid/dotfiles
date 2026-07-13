## Step 3 — Write Commit Messages

For each commit in the plan, write a message following the `~/.gitmessage` template:

```
<subject line>

Why
---

- <reason 1>
- <reason 2>

How
---

- <approach 1>
- <approach 2>

Side Effects
------------

- <side effect 1>

Related Cards
-------------

- [Card Name](url)
```

### Subject Line
- Max 50 characters
- Imperative mood ("Add", "Fix", "Refactor", not "Added", "Fixes", "Refactoring")
- No period at the end
- Specific — "Add webhook retry logic" not "Update code"

### Why
Explain the motivation — not what changed, but **why** it needed to change:
- What problem was being solved?
- What user need, bug, or technical debt drove this?
- What was the previous behavior and why was it insufficient?
- If the why is obvious from the subject line alone (e.g. a typo fix), a single brief bullet is fine

### How
Explain the approach taken — the key decisions and tradeoffs:
- What strategy was chosen and why?
- What alternatives were considered (if non-obvious)?
- What's the high-level structure of the change?
- For multi-file changes, describe how the pieces fit together
- Don't just restate the diff — explain the thinking behind it

### Side Effects
Describe anything this change affects beyond its primary intent:
- Behavior changes in other parts of the system
- New dependencies introduced
- Migration or deploy steps required
- Performance implications
- Breaking changes to APIs or interfaces
- If there are genuinely no side effects, write "- None"

### Related Cards
- If `$ARGUMENTS` included a ticket reference, link it here: `- [ENG-123](url)`
- If the branch name contains a ticket reference, include it
- If a Linear ticket is linked, fetch the title for the card name
- If there are no related cards, write "- None"
