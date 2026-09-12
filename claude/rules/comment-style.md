# Comment Style

A comment earns its place by carrying reasoning the code cannot show on its
own. It explains **why** the code exists or behaves as it does — a
constraint, a tradeoff, a rejected alternative, a gotcha. It never narrates
**what** the code does or **how** it does it; that's the code's own job, and a
fluent reader of the language already sees it.

## Constraints

- Do not add a comment that restates the next line in prose (`# increment
  counter` above `counter += 1`, `// loop over users` above `for user in
  users`). If a comment adds nothing beyond what the syntax already says,
  delete it rather than write it.
- Do not narrate control flow, data structures, or step-by-step mechanics the
  code already shows. That belongs in a variable name, function name, or
  extracted helper — not a comment.
- Do write a comment when the reasoning is not recoverable from the code
  itself: a business rule the code encodes, a workaround for a specific
  bug/library limitation, a rejected simpler approach and why it failed, an
  ordering or performance constraint, a legal/compliance requirement, or a
  pointer to the ticket/incident that explains the shape of the fix.
- When a comment could instead be a better name (function, variable,
  constant), rename instead of commenting. A comment is the fallback for
  reasoning naming cannot carry, not a substitute for naming well.
- A public API's doc-comment (parameters, return shape, error conditions) is
  a contract for callers who won't read the implementation — that's
  documentation, not narration, and stays.
- Code that needs no comment to be understood should have none. Silence is
  the correct output, not a gap to fill.

## Examples

Bad — explains *what*:
```python
# check if user is admin
if user.role == "admin":
```

Good — explains *why*:
```python
# Billing exports stay admin-only until the SOC2 audit closes.
if user.role == "admin":
```

Bad — explains *how*:
```python
# loop through items and sum the non-refund values
total = sum(item.value for item in items if not item.is_refund)
```

Good — explains *why*, and only because it isn't obvious:
```python
# Refunds are excluded: their negative values would double-count against gross revenue.
total = sum(item.value for item in items if not item.is_refund)
```
