## Step 1 — Gather the Spec

### From Linear (primary source)
Fetch the linked ticket using Linear MCP tools:
- Title, description, acceptance criteria
- Sub-issues and their acceptance criteria
- Parent issue/project for broader context
- Comments — especially from PM, design, or stakeholders that clarify intent

### From PR Description
- PR description and any linked documents
- Commit messages for intent signals
- Linked Notion docs, Figma files, or external specs referenced in the PR

### From Notion (supplementary)
Search Notion for related design docs, RFCs, or specs:
- Pages that reference the Linear ticket ID
- Recent pages with matching feature/project names
- Meeting notes where requirements were discussed or refined

### Build the Requirements Map

Produce a structured requirements list:

```markdown
| # | Requirement | Source | Priority | Implicit Edge Cases |
|---|------------|--------|----------|-------------------|
| R1 | [Acceptance criterion verbatim] | [Linear/Notion/PR] | [Must/Should/Nice] | [Edge cases implied but not stated] |
```

**Implicit edge cases** — for every requirement, identify the unstated scenarios:
- What happens when the input is empty, nil, or malformed?
- What happens for the first/last item? For zero items? For one item?
- What happens when the user doesn't have permission?
- What happens when an external dependency is unavailable?
- What happens when the operation is retried or performed concurrently?

Present the requirements map to the user:
> "Here are the requirements I've extracted and the edge cases I'm inferring — is this complete and accurate?"

Do NOT proceed until confirmed.
