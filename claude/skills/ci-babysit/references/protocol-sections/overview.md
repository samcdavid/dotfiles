---
model: sonnet
name: ci-babysit
description: Monitor a PR's CircleCI pipeline until all jobs pass. Polls for status, diagnoses failures, applies fixes, pushes, and re-monitors. Does not stop until the entire pipeline is green or you intervene.
disable-model-invocation: true
---

# CI Babysit

Monitor a PR's CircleCI pipeline from start to finish. When something fails, diagnose it, fix it, push the fix, and keep watching. Do not stop until every job in the pipeline is green.
