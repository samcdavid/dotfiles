# Structural Code Search

When a search is structural — find definitions of a name, find its call
sites, find every node matching an AST shape (e.g. "every function that
takes no arguments") — reach for `tree-sitter` via Bash before grep/ripgrep.
Structural questions are exactly where a text match produces false
positives (a comment or string containing the name) and false negatives (a
call spread across lines) that an AST match does not.

Keep plain substring/text search (an error string, a config key, a literal
you already know the spelling of) on the Grep tool/ripgrep — that is what
it's for, and tree-sitter has no text-search mode to replace it with.

Mechanics:

- `tree-sitter tags <path>` lists definitions and call/reference sites with
  line ranges — the first thing to reach for; it needs no query file.
- `tree-sitter query <query.scm> <path>` runs a custom AST-shaped pattern
  when `tags` isn't precise enough. Write the `.scm` query to a scratch file
  first; there is no inline-query flag.
- `tree-sitter parse <path>` dumps the raw s-expression tree — use it to
  find the node names a query needs, not as a search method itself.

Grammars only cover languages actually cloned into
`~/.local/share/tree-sitter/grammars` (registered in
`~/.config/tree-sitter/config.json`'s `parser-directories`). Currently:
Python, JavaScript, TypeScript, Ruby, Go, Bash, Lua, JSON, YAML, Fish,
Elixir. Run `tree-sitter dump-languages` if a language's coverage is
uncertain — do not assume a grammar exists — and fall back to grep/ripgrep
outright for anything not listed there rather than stalling the search on
missing coverage.
