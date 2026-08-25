# Post-Review Loop

This reference is retained only for historical links. `my-workflow` no longer runs a
post-review loop directly. Dispatch `implement-review`; it is the sole owner of
implementation, validation, review, repair, and the five-pass cap. Do not invoke
`address-pr-feedback local` from the workflow atomic block.
