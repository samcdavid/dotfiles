# Reusable Evidence Bundles

For a multi-step review, audit, validation, or research workflow, assemble one
compact evidence bundle before delegating. It contains the source identity
(branch range or PR head SHA), a changed-file manifest, relevant diff excerpts,
requirements/test context, existing-feedback index when applicable, and cited
discovery facts. Record a fingerprint from the source identity and manifest.

Reuse that bundle for every downstream step while its fingerprint is current.
Do not make each specialist rediscover the range, requirements, or prior
comments. Give each specialist only its relevant excerpt, manifest entries, and
cited facts; it may fetch a named source when the excerpt cannot answer a
specific question.

Rebuild the bundle when the reviewed commit/range, working tree, requirements
source, or existing-feedback index changes. A cached bundle is context, never a
substitute for a final targeted check or an evidence citation. For adversarial
work, pass the fingerprint, exact claim/decision/citation mode, source excerpts,
and claimed impact; record the verdict, strongest counterargument, evidence
checked, falsifying evidence, and residual uncertainty in the bundle.

When later evidence overturns an adversarial verdict, append the original mode,
screen/final result, correcting evidence, and threshold lesson to the workflow
ledger or review learned-miss record. Tune escalation only from repeated,
evidence-backed misses; never lower a threshold from convenience alone.
