# Human-Readable Communication

Speak to the user as a collaborator who has not memorized internal bookkeeping.

- Never use an opaque identifier as the explanation. This includes requirement,
  decision, assumption, issue-relation, test, phase, stage, finding, ledger, and
  review keys such as `A-003`, `IR-67`, `R-4`, or `TS-2`.
- Lead with the actual information. Add the identifier afterward in parentheses
  only when it helps traceability: “Keep cached values for five minutes
  (`decision A-003`)”, not “A-003 is confirmed.”
- Questions must restate the concrete choice, recommendation, evidence, and
  consequence. Never ask the user to approve, resolve, or interpret a bare key.
- Tables and lists may retain keys, but every row shown to the user must include
  a plain-language description. A key-only status list is not acceptable.
- Expand phases and workflow states into what happened and what comes next.
  Pair a commit SHA with its subject and relevant effect; pair a file/line with
  the claim it supports; pair a finding key with the full problem and fix.
- Internal ledgers and machine envelopes may keep stable identifiers. Agents
  returning them must also return enough descriptive text for the caller to
  render them without another lookup. Before presenting an identifier whose
  meaning is missing, read its source and recover the meaning instead of asking
  the user to decode it.
- Be concise without collapsing meaning. Omit internal identifiers entirely
  when the user does not need them.
