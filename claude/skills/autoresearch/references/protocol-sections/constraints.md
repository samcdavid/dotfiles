## Constraints

- **NEVER STOP** (unless iteration limit reached, agent returns `blocked`, or user interrupts) — the user may be away.
- **NEVER ASK** the user mid-loop. If genuinely stuck, the agent returns `blocked` and the loop halts.
- **Git is memory** — every kept change is committed. The agent reads `git log` to learn patterns.
- **Mechanical only** — the verify command is the only judge. Subjective "looks good" is not used.
- **Read-only paths are absolute.** If the agent reports it touched one, the iteration was already auto-discarded.
