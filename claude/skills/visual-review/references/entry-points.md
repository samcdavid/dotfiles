# Entry points

Find every way to reach the capability the change touches, classify each, and compare the rules each applies.

**Where to look.** Other UI surfaces, API/GraphQL/MCP, bulk import, clone or duplicate, templates, jobs, seeds, admin tools.

**How to search.** For every writer of the same schema and every caller of the same core function, use `ast-grep` patterns first (they skip comments and strings), then LSP references where available, then `rg` for what a parser can't resolve: routes, config, string-keyed dispatch, and aliased or dynamic calls (`alias ... as`, `import ... as`, `apply`, `send`). Neither a parser nor an LSP resolves every alias or dynamic call, so list what you searched in the page footer.

**Kinds.**
- `shared`: same core, same rules.
- `bespoke`: reimplements the core, or reaches it under its own rules, such as a narrower input list or its own validation.
- `new`: added by this change.

**Rules to compare.** Validation, defaults, authorization, limits, side effects (events, jobs, notifications, analytics, audit), flags, and error and UI copy. A rule applied on one path and not the others is drift; flag it.
