# Entry points

Find every way to reach the capability the change touches, classify each, and compare the rules each applies.

**Where to look.** Other UI surfaces, API/GraphQL/MCP, bulk import, clone or duplicate, templates, jobs, seeds, admin tools.

**How to search.** For every writer of the same schema and every caller of the same core function, use `ast-grep` patterns first (they skip comments and strings), then LSP references where available, then `rg` for what a parser can't resolve: routes, config, string-keyed dispatch, and aliased or dynamic calls (`alias ... as`, `import ... as`, `apply`, `send`). Neither a parser nor an LSP resolves every alias or dynamic call, so list what you searched in the page footer.

**Kinds.**
- `shared`: reaches the one existing implementation. Its rules can still differ (a narrower input list, an extra option); that shows as `differs` in the table, not as bespoke.
- `bespoke`: a separate implementation of functionality that already exists, so keeping the two the same means changing both.
- `new`: added by this change. Mark it beside `shared` or `bespoke`. `bespoke` plus `new` is a second implementation this change introduces, so scrutinize it hardest.

**Intent.** For every `bespoke` row, say whether the PR, ticket, or code says the two should behave the same. If so, name what has to change in both places and raise it as a technical risk. If the intent isn't stated, say so in the risk.

**Rules to compare.** Validation, defaults, authorization, limits, side effects (events, jobs, notifications, analytics, audit), flags, and error and UI copy. A rule applied on one path and not the others is drift; flag it.
