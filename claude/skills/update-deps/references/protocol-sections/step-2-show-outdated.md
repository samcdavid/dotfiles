## Step 2: Show Outdated

Run the outdated command and present the results. Identify safe updates vs breaking changes.

| Manager | Outdated command | Notes |
|---------|-----------------|-------|
| `mix` | `mix hex.outdated` | Major version bump = breaking |
| `npm` | `npm outdated` | Red = wanted (safe), yellow = latest (may break) |
| `yarn` | `yarn outdated` | Similar to npm |
| `pnpm` | `pnpm outdated` | Similar to npm |
| `bun` | `bun outdated` | Similar to npm |
| `uv` | `uv pip list --outdated` or `uv lock --check` | Check pyproject.toml constraints |
| `poetry` | `poetry show --outdated` | Major version bump = breaking |
| `pip` | `pip list --outdated` | Compare against pinned versions |
| `cargo` | `cargo outdated` (if installed) or `cargo update --dry-run` | SemVer-aware |
| `go` | `go list -m -u all` | Check for major version module paths |
| `bundler` | `bundle outdated` | Major version bump = breaking |
| `composer` | `composer outdated` | SemVer coloring |

**Classify each dependency:**
- **Safe**: patch or minor version bump within current constraints
- **Breaking**: major version bump or requires constraint change

Present the list to the user. Ask if they want to proceed with all updates, or select specific ones.
