# Feedback Triage

Load this after fetching PR feedback.

For every pending comment:

1. Read the comment in code context.
2. Verify suggested utilities, patterns, library behavior, and caller impact.
3. Consult `pushback-patterns.md` for calibrated response shapes.
4. Classify as Confirmed Fix, Partially Correct, Question, Valid Deferral, Disagree/Push Back, or Already Addressed.
5. Run `adversarial-debate` on classifications before acting.

For DRY/deduplication requests, count actual occurrences. Three or fewer occurrences usually supports evidence-backed pushback; more than three usually supports extraction.

