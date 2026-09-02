# Post-Review Loop

This reference is retained only for historical links. `my-workflow` completes
`my-implement`, then runs one whole-plan `my-validate` gate before dispatching
`implement-review`. The latter is the sole owner of post-implementation review,
repair validation, and the five-pass cap; it never owns initial plan execution.
Do not invoke `address-pr-feedback local` from this sequence.
