## Skill Catalog

### Planning & Specs
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `my-spec` | Refines vague ideas into well-scoped specs with acceptance criteria | Starting from a rough idea, bug report, or request |
| `my-clarify` | Surfaces ambiguities and unstated assumptions in existing specs | After writing a spec, before planning |
| `my-analyze` | Cross-artifact consistency analysis (specs vs research vs plans) | Before implementation, to catch contradictions |
| `my-plan` | Creates detailed implementation plans with verifiable success criteria | After spec is solid, before coding |

### Research & Investigation
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `my-research` | Deep codebase research with parallel agents and cross-referencing | Need to understand how something works |
| `my-investigate` | Explores logs, metrics, traces to find root cause | Production/runtime issues |
| `autoresearch` | Autonomous iteration loop — modify, verify, keep/rollback, repeat | Measurable optimization goals (tests, benchmarks, coverage) |

### Implementation
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `my-implement` | Orchestrates a plan phase-by-phase, dispatching each to an isolated executor doing red/green/validate TDD | After plan is approved |
| `commit` | Groups changes into logical commits with detailed messages | After implementation, ready to commit |
| `update-deps` | Updates all outdated dependencies with changelog lookup | Dependency maintenance |

### Quality & Review
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `my-review` | Rigorous code review (correctness, contracts, idempotency, perf) | Reviewing local changes or PRs |
| `my-arch-review` | Architecture review (coupling, cohesion, boundaries, conventions) | Evaluating structural decisions |
| `perf-review` | Deep performance review (queries, indexes, caching, load) | Performance-sensitive changes |
| `security-audit` | Deep security audit (OWASP, auth, injection, CVEs, secrets) | Security-sensitive changes |
| `quality-audit` | Test quality audit (coverage, fidelity, flakiness, assertions) | Evaluating test suite health |
| `requirements-audit` | Traces acceptance criteria to code, finds gaps and scope creep | Verifying feature completeness |
| `my-validate` | Verifies work against a plan or session context, attempts self-repair | Post-implementation sanity check |
| `publish-review` | Posts a formatted PR review to GitHub | After completing a review |
| `address-pr-feedback` | Systematically addresses all pending PR review comments | After receiving PR feedback |

### Testing
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `my-test-plan` | Designs manual E2E test scenarios from ticket + PR | Before manual testing |
| `my-test-exec` | Executes test plan in Chrome, records GIF, formats results | Running manual E2E tests |
| `my-eval-plan` | Designs evaluation plans for AI/LLM features (platform-agnostic) | Planning evals for AI features |

### Adversarial & Verification
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `prove-it` | Fact-checks the conversation — verified vs unverified claims | Findings feel uncertain |
| `you-sure` | Adversarial confidence challenge with independent agent verification | Before acting on recommendations |
| `this-important` | Importance filter on findings from a previous response — drops noise so only items worth raising/addressing survive | After a review, audit, or list of recommendations; auto-invoked by `my-review` and `address-pr-feedback` |

### Workflow & Productivity
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `daily-summary` | Summarizes yesterday, generates standup, builds today's checklist | Start of day |
| `log-work` | Logs session accomplishments to Notion daily doc | End of session |
| `pulse` | Digest of recent codebase activity across all contributors | Understanding what changed recently |
| `my-next` | Synthesizes session state into prioritized action plan | Lost in the weeds, need direction |
| `walk-through` | Walks through a list one item at a time with focused discussion | Processing a multi-item list |
| `ci-babysit` | Monitors CI pipeline, diagnoses failures, fixes and re-pushes | Waiting for CI to go green |

### Observability
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `my-observe` | Designs metrics, traces, spans, and monitors for code changes | Adding observability to new features |

### Safety & Guardrails
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `careful` | Blocks destructive commands (rm -rf, DROP TABLE, force-push) | Working near production or critical infrastructure |
| `freeze` | Blocks file edits outside a specified directory | Debugging — prevent accidental changes elsewhere |
| `context-audit` | Audits context window usage and helps drop unnecessary content | Context window feels bloated or performance degrades |

### Meta
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `gotcha` | Captures a failure pattern as a gotcha for an existing skill | Claude made a mistake worth remembering |
| `help-skills` | This skill — find the right skill for your task | You don't know which skill to use |
