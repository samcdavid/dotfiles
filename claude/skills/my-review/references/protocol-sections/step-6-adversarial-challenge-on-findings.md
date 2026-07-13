## Step 6 — Adversarial Challenge on Findings

Format all Critical findings, non-blocking suggestions, questions, and nits as structured findings. Pass them to `adversarial-debate` with:

- PR diff or local diff source of truth
- referenced file paths and lines
- requirements checklist, if present
- proposed severity
- proposed verdict

The agent returns KEEP, DOWNGRADE, REVISE, or DROP with evidence.

PR mode caveat: adversarial agents can accidentally read the local working tree. If a DROP/REVISE verdict depends on "file does not exist," "identifier is fabricated," or "function cannot be found," verify against the PR diff or PR HEAD before applying it.

Apply verdicts:

- KEEP: present as-is.
- DOWNGRADE: move Critical to non-blocking/question, or suggestion to nit/drop.
- REVISE: update claim, severity, or fix.
- DROP: remove and note in Dropped Findings.

After adversarial review, run `/this-important strict` unless the user explicitly asked for a broader sweep. Do not let `/this-important` upgrade to `REQUEST_CHANGES` unless the finding meets the Critical merge-blocking bar.

Before Step 7, confirm:

- no finding duplicates an existing PR thread
- every finding is grounded in the diff or verified source
- every Critical finding truly blocks merge
- dropped findings have one-line reasons

