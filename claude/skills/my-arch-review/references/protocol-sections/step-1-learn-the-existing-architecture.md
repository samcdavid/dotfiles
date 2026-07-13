## Step 1 — Learn the Existing Architecture

Before evaluating anything, understand the system as it exists today. Spawn parallel agents:

- **codebase-locator**: Map the top-level directory structure, module boundaries, and key entry points
- **codebase-analyzer**: Trace dependency directions between major modules — what imports what, what calls what
- **codebase-pattern-finder**: Identify the established conventions — file organization, naming patterns, layering, how similar changes were structured before

Look for:
- Project CLAUDE.md, AGENTS.md, or architecture docs that define intended structure
- Existing ADRs (Architecture Decision Records) in `docs/`, `adr/`, or similar
- Dependency layering (e.g., Types → Config → Repo → Service → Runtime → UI)
- Module boundary patterns (how the codebase separates concerns today)

State your understanding of the architecture before proceeding:
> "Here's how I understand the current architecture and its conventions — is this accurate?"
