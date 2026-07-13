## When to use this skill

Use `/my-quick` when ALL of these are true:
- The change is well-understood — I can describe what to do in a sentence
- The blast radius is small and obvious
- No new module, no migration, no auth, no cross-service contract change
- Existing code in scope is familiar and well-named — no spelunking needed

Use the heavy pipeline (`/my-research → /my-spec → /my-clarify → /my-plan → /my-analyze → /my-implement → /my-validate → /my-review`) when ANY of those is false. The tripwire in Step 3 catches the common cases, but author judgment is the primary gate.
