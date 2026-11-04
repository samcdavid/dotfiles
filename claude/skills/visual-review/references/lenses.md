# Lenses

A lens is a way of reading the flow, not a second review. Take each lens's checks from its file and leave its procedure: no scope questions, confirmations, subagents, report template, or challenge step. This skill has its own.

| Lens | Checks | Read the flow as |
|---|---|---|
| Security (always) | `my-review/references/lenses/security.md`: OWASP, data exposure, secrets | A set of ways in. Check authn, authz, input validation, and rate limits on every entry point; a `bespoke` or `new` row that skips a check the shared path makes is the usual miss. Then edges that cross a trust boundary, data leaving (responses, logs, third-party calls, emails), and tokens. |
| Architecture (always) | `my-review/references/lenses/architecture.md`: structural fit, coupling, boundaries, deviations; plus `my-review/references/cross-service-contracts.md` when an edge crosses a service | A dependency graph. Edges that cross a module, layer, or service the wrong way, logic in the wrong layer, `bespoke` duplicates, and a new pattern beside an established one. Judge each deviation desirable or not, with the reason; a desirable one is not a risk. |
| Performance | `my-review/references/lenses/performance.md`: queries, resources, caching, scale | Nodes that query, loop, or enqueue at real volume. |
| QA | `my-review/references/lenses/quality.md`: coverage, fidelity, placement | An `added` or `modified` node with no test that would fail if it broke, and a changed existing test. |
| PM | `my-review/references/lenses/requirements.md`: traceability, scope, edge cases | A requirement with no node, a node no requirement asked for, user-visible copy and states. |
| Backend, Frontend, Full-stack, Ops, Migration safety, Dependency | the matching sections of `my-review/references/general-checklist.md` | Failure edges that aren't retried or reported, idempotency, migrations, rollout and config, and the contract between layers. |

Also apply the code-level entries of `my-review/gotchas.md` that fit the diff, such as contract divergence between services, prompt or tool-docstring changes without an eval, and brand capitalization in copy.

**On the page.** The Lenses table has a row for every lens that ran, `data-lens` set to its lowercase name:
- why it ran, naming the trigger in the diff (Security and Architecture say "always");
- what it checked on the flow, naming nodes and entry points, never just "reviewed";
- what it found, as links to its risks. A lens that found nothing says so, and links any risk it dismissed.

Every risk carries its lens as a chip beside its title and as `data-lens`, and the table row for that lens links it.
