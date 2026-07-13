## Step 1 — Understand the Change

Read the code changes fully. Spawn parallel agents:
- **codebase-analyzer**: Understand the implementation, data flow, and failure modes
- **docs-researcher**: Look up observability best practices for the specific frameworks/libraries in use

Identify:
- What are the CRITICAL operations? (must succeed for the feature to work)
- What are the EXPECTED failure modes? (network timeouts, invalid input, rate limits)
- What are the UNEXPECTED failure modes? (logic bugs, data corruption, silent failures)
- What downstream systems are affected?
