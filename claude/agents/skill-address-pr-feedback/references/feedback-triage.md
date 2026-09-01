# Feedback Triage — skill-address-pr-feedback

Load this after fetching PR feedback.

For every pending comment:

1. Read the comment in code context.
2. Verify suggested utilities, patterns, library behavior, and caller impact.
3. Consult `pushback-patterns.md` for calibrated response shapes.
4. Classify as Confirmed Fix, Partially Correct, Question, Scope Decision Required, Valid Deferral, Disagree/Push Back, or Already Addressed.
5. Screen direct classifications with `adversarial-screen` in `finding` mode and
   a fingerprinted evidence bundle; escalate only material, contradictory, or
   disputed-scope classifications to `adversarial-debate` in `finding` or
   `decision` mode before acting.

## Scope decision required

Use this classification when the technically safest response would disable, defer,
or otherwise narrow behavior that an active requirement says must ship. Record the
requirement, the technical reason, and the two clearing paths:

1. implement the required behavior in the current change; or
2. obtain an explicit requirements amendment from the authorized owner.

A related issue, backlog ticket, code comment, or reviewer suggestion to "gate it
off for now" is not an amendment. Do not plan or implement the workaround until
the decision is explicit.

## Triage breadth

Group comments that share one root cause and plan one fix for that root cause.
Treat nits, speculative performance improvements, and coverage extensions as
visible non-blocking deferrals unless they are necessary to validate a selected
behavioral fix. Never turn "address feedback" into "implement every suggestion."

For DRY/deduplication requests, count actual occurrences. Three or fewer occurrences usually supports evidence-backed pushback; more than three usually supports extraction.
