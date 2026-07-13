## Guidelines

- **Research, then plan, then implement.** Don't jump to editing code — investigate every comment into a verified finding (Act I), slice the confirmed fixes (Act II), then execute (Act III).
- **You orchestrate; the executor implements behavioral fixes.** Don't write a behavioral fix's tests or production code in the main context — dispatch it to `implementation-executor` and re-verify. Only non-behavioral trivia is yours to edit directly.
- **One executor at a time.** Fixes are sequential; they share the working tree and may touch overlapping files.
- **TDD for behavioral fixes is not optional.** A behavioral phase with no honest RED test either gets a real test or moves to the direct-edit track — never a vacuous test to satisfy the executor.
- **Investigate first, act second.** Every comment — agree or disagree — deserves investigation before you decide how to respond.
- **Fix first, respond second.** Apply all code changes before drafting responses, so responses can reference specific commits.
- **Show your work.** Responses should demonstrate investigation — what you checked, what you found, why. "Fixed in abc123" without context tells the reviewer nothing.
- **One concern per commit when possible.** Makes it easy for reviewers to verify each fix maps to their feedback.
- **Never argue style.** If a reviewer prefers a different but equally valid approach, adopt it. Reserve push back for correctness and constraints.
- **Deferred is not forgotten.** Every deferral needs a concrete follow-up plan, or it's not a deferral — just do it.
- **Don't fix what wasn't flagged.** Address the feedback, nothing more — no refactoring surrounding code while you're in the file.
- **Verify before declaring done.** A PR with addressed feedback that doesn't build is worse than unaddressed feedback.
