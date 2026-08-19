# Gotchas

## Honor confirmed PR-mode publication authority

- **Trigger:** A user confirms PR-mode feedback triage and the workflow reaches the validated publication step.
- **Wrong behavior:** Apply the generic no-outward-actions default after that confirmation and stop with local commits, unposted replies, and unresolved threads.
- **Correct behavior:** Treat the PR-mode triage confirmation as authorization to push the validated commits, reply in every addressed thread, resolve those threads, and re-request eligible reviewers. Stop only when the user explicitly narrows or revokes that scope.
- **Why it matters:** The feedback workflow's confirmation gate exists specifically to authorize the complete review round; treating it as local-only leaves the PR visibly unfinished.

## Run and verify the full relevant lint suite before completing a fix

- **Trigger:** Completing a PR-feedback fix, especially after a focused test or partial lint check passes.
- **Wrong behavior:** Infer lint success from truncated/asynchronous output, or stop after a targeted check without running the repository's relevant full lint command.
- **Correct behavior:** Before reporting completion or pushing, run the full relevant lint suite specified by the project or CI and verify its final zero exit status. If that status cannot be captured, report validation as inconclusive; a targeted check only supplements, never replaces, the full suite.
- **Why it matters:** Static analysis can report its sole violation late in a broad scan, leaving CI red after a falsely reported completion.

## Reconcile feedback with the workflow ledger before accepting it

- **Trigger:** Any review finding on a branch with a `my-workflow` ledger.
- **Wrong behavior:** Classify a plausible review comment as a fix before checking whether it conflicts with a settled ledger decision, plan constraint, or documented scope boundary.
- **Correct behavior:** Verify every finding against the ledger first. If it conflicts, push back with the ledger's specific decision and rationale; implement only when new evidence or an explicit user decision supersedes it.
- **Why it matters:** The ledger is the durable record of accepted trade-offs, so ignoring it reopens decisions that the workflow has already settled.

## Complete the PR feedback publication sequence

- **Trigger:** PR-mode triage is confirmed and reply publication is authorized.
- **Wrong behavior:** Post replies but unilaterally leave the review threads open.
- **Correct behavior:** After replies succeed, resolve every addressed inline thread, then re-request eligible non-approving reviewers unless the user explicitly narrows that scope.
- **Why it matters:** Open threads leave resolved feedback looking unfinished and make the PR's review state misleading.

## Do not exclude outdated conversations when resolving PR feedback

- **Trigger:** A user asks to reply to and resolve PR conversations after a rebase or force-push.
- **Wrong behavior:** Filter review threads to non-outdated comments, then report the PR clean while outdated conversations remain unresolved and unreplied.
- **Correct behavior:** Unless the user explicitly limits scope, enumerate every unresolved review thread regardless of `isOutdated`, reply with the current rebased resolution (or a concise rationale), resolve each thread, and verify the unresolved-thread count is zero.
- **Why it matters:** GitHub retains outdated review conversations as visible unresolved work; leaving them open makes the review look incomplete and breaks the user's requested cleanup.

## Test both directions of a gate helper's contract

- **Trigger:** Adding or reviewing a shared authorization, rollout, or registration wrapper.
- **Wrong behavior:** Cover only hidden/denied paths and infer that the permitted handler path works.
- **Correct behavior:** Add a focused allowed-path test that asserts authenticated identity and arguments reach the resolver, ordering is resolver → gate → handler, the handler runs exactly once, and its result is returned. Prefer a temporary mutation check when practical.
- **Why it matters:** Denial-only tests can stay green when the wrapper drops the handler invocation, return value, or forwarded arguments.

## State the authorization responsibility of injected resolvers

- **Trigger:** A helper accepts an account/resource resolver and applies a later feature or account gate.
- **Wrong behavior:** Describe the resolver as merely returning an ID, allowing future callers to trust a client-supplied identifier.
- **Correct behavior:** Document and test that the resolver establishes the caller's membership/ownership access before returning the target ID; the later rollout gate is not an authorization substitute.
- **Why it matters:** A global allowlist keyed by account/resource can approve an otherwise unauthorized caller if the resolver bypasses membership checks.

## Audit new registration helpers against the platform wrapper contract

- **Trigger:** Introducing a custom replacement for a shared registration decorator such as `@mcp.tool`.
- **Wrong behavior:** Validate only the new helper's local gate and overlook inherited contracts such as telemetry wrapping, session validation order, and context enrichment.
- **Correct behavior:** Before merge, trace the registered callable's wrapper order and confirm how the helper composes with required instrumentation/session/context behavior; add a real-handler regression when the first live tool defines that composition.
- **Why it matters:** A locally correct gate can still bypass observability or perform account work before a shared precondition rejects the call.

## Treat focused static analysis as part of a typed wrapper's acceptance check

- **Trigger:** Forwarding `**kwargs` into a third-party decorator/function with typed overloads, or asserting decoded JSON deeply in tests.
- **Wrong behavior:** Use `object` for forwarded options or generic JSON maps, then validate only tests and formatting.
- **Correct behavior:** Inspect the concrete dependency signature, model allowed keyword options with `Unpack[TypedDict]` (or a justified narrower type), narrow decoded JSON before nested access, and run Ruff *check* plus focused BasedPyright.
- **Why it matters:** Type noise masks real future errors and a format-only check misses lint violations in otherwise passing review fixes.
