# Verification Ladder

Use the narrowest check that can disprove a bounded edit first: the changed test,
lint/format target, build target, or dependency/install check. Run broader
package or repository checks only after the narrow check passes, and run the
full required suite at the workflow's terminal gate.

If a narrow check fails, diagnose before widening the command. After an edit,
rerun the exact failing check and inspect the diff. A broad green suite never
substitutes for the targeted proof of the changed behavior. Record each command
and result once in the reusable evidence bundle; rerun only after relevant code
or environment inputs change.
