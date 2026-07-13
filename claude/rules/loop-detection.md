# Loop Detection

Use a three-strike rule for repeated failures:

1. First failure: diagnose and tighten the brief or fix the local issue.
2. Second same-root failure: make one targeted retry.
3. Third same-root failure: stop and report the phase, command, repeated output, attempts made, and best root-cause theory.

Do not keep dispatching agents or rerunning the same command without new information.

