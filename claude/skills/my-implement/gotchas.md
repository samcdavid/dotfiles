# Gotchas

## Elixir database tests must use SQL Sandbox

- **Trigger:** Adding, repairing, or debugging an Elixir test that connects to the database.
- **Wrong:** Bypass `Ecto.Adapters.SQL.Sandbox`, use an unboxed checkout or independent physical connection, add manual database cleanup, or make production code aware of sandbox ownership.
- **Correct:** Run every test database operation through the test process's normal SQL Sandbox connection. Share sandbox access with supervised child processes using test-support mechanisms only when needed, and assert externally observable outcomes rather than connection topology or backend session identity.
- **Why:** Sandbox ownership provides per-test isolation and automatic rollback. Bypassing it leaks state across tests; coupling production code to it contaminates runtime behavior with test infrastructure.
