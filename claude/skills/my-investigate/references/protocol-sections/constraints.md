## Constraints

- **Read-only investigation.** The skill and the agent are both forbidden from applying mitigations, modifying configuration, restarting services, paging anyone, or editing code in the affected codebase. Surface options; the user decides.
- **Follow evidence, not intuition.** Every conclusion needs a data point.
- **Specific over vague.** Quote log lines, list trace IDs, name exact metric values. "The logs looked bad" is not evidence.
- **User-paced.** Ask before moving from investigation → mitigation → fix → verification. Each transition is a decision point.
