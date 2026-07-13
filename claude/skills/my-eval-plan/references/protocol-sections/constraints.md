## Constraints

- Design evals BEFORE building them. This skill produces the plan, not the code.
- Be platform-agnostic in the plan. Note where platform-specific features would help (e.g., "Braintrust's tracing would be useful here") but don't couple the plan to any vendor.
- Don't over-engineer. Start with the 2-3 most important dimensions and expand later. A simple eval that runs is better than a comprehensive one that doesn't.
- Every scorer needs a failure example — if you can't describe what failure looks like, the scorer isn't well-defined.
- Flag when human review is genuinely needed vs. when an LLM judge would suffice. Human review is expensive — use it for calibration, not bulk scoring.
