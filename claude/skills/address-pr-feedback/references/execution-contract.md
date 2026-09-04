# Feedback Execution Contract

Load this at triage, before the combined validation gate, and before a wrapper
performs authorized PR actions. It holds workflow obligations; they are not
gotchas.

## Context and Validation

- Discover the branch workflow ledger before classifying feedback. Its settled
  decisions and Finding Register are evidence, not optional context.
- The combined gate runs the repository's relevant build/compile and test
  commands. Lint and formatting are the project's own pre-commit hooks'
  responsibility, not this gate's. Capture each final exit status. A targeted
  check supplements this gate; it never replaces it.
- Do not report a fix complete while a required check is failed or inconclusive.

## Authorized PR Execution

Only the wrapper performs outward actions, and only after the user explicitly
authorizes the returned execution envelope. Before pushing, compare local and
remote heads; push only the explicitly authorized fix SHA when unrelated local
commits have advanced HEAD.

After a successful authorized push, post every prepared reply, including
outdated unresolved review threads unless the user narrowed scope; resolve every
addressed thread; then re-request only eligible reviewers whose latest review is
not approval. Verify the requested publication actions and remaining unresolved
thread count before reporting completion.

The runner never performs these actions. It returns the exact requested actions,
targets, order, drafts, and evidence for the wrapper to execute.
