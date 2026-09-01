# Protocol — update-deps

Full step flow for this skill. `SKILL.md` is the entrypoint; this file holds the detail. Standalone references (gotchas, checklists, mined patterns) remain separate files in `references/`.

## Update Dependencies

Update all outdated dependencies in the current project. Auto-detects language, package manager, and verification commands.

## Step 1: Detect Project

Scan the working directory for manifest files. Use the FIRST match — if multiple ecosystems exist (e.g. monorepo), ask the user which to update.

| Manifest file | Ecosystem | Next: detect package manager |
|---------------|-----------|------------------------------|
| `mix.exs` | Elixir | Always `mix` |
| `package.json` | Node/TypeScript | Check lockfile (step below) |
| `pyproject.toml` | Python | Check lockfile/tool config (step below) |
| `requirements.txt` (no pyproject.toml) | Python | `pip` |
| `Cargo.toml` | Rust | Always `cargo` |
| `go.mod` | Go | Always `go` |
| `Gemfile` | Ruby | Always `bundler` |
| `pubspec.yaml` | Dart/Flutter | Always `dart pub` / `flutter pub` |
| `build.gradle` / `build.gradle.kts` | JVM | `gradle` |
| `pom.xml` | JVM | `maven` |
| `composer.json` | PHP | Always `composer` |

### Node/TypeScript package manager detection

Check in order — first lockfile found wins:

1. `bun.lockb` or `bun.lock` -> `bun`
2. `pnpm-lock.yaml` -> `pnpm`
3. `yarn.lock` -> `yarn`
4. `package-lock.json` -> `npm`
5. Check `packageManager` field in `package.json` if no lockfile
6. Fallback: `npm`

### Python package manager detection

Check in order:

1. `uv.lock` -> `uv`
2. `poetry.lock` -> `poetry`
3. `pdm.lock` -> `pdm`
4. `Pipfile.lock` -> `pipenv`
5. Check `[tool.poetry]` in `pyproject.toml` -> `poetry`
6. Check `[tool.pdm]` in `pyproject.toml` -> `pdm`
7. Check `[build-system] requires` for `hatchling` -> `hatch`
8. Fallback with `pyproject.toml`: `uv` (if available) or `pip`
9. Fallback with `requirements.txt` only: `pip`

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

## Step 3: Apply Safe Updates

For each approved safe update batch, invoke `my-implement` with the native update
command, manifest/lockfile `allowed_paths`, and install/build/lint/test success
criteria. It performs the mechanical update; independently review the manifest
and lockfile diff before proceeding.

| Manager | Safe update command |
|---------|-------------------|
| `mix` | `mix deps.update --all` |
| `npm` | `npm update` |
| `yarn` | `yarn upgrade` (v1) or `yarn up` (v2+) |
| `pnpm` | `pnpm update` |
| `bun` | `bun update` |
| `uv` | `uv lock --upgrade` then `uv sync` |
| `poetry` | `poetry update` |
| `pip` | `pip install --upgrade <pkg1> <pkg2> ...` |
| `cargo` | `cargo update` |
| `go` | `go get -u ./...` then `go mod tidy` |
| `bundler` | `bundle update --conservative` |
| `composer` | `composer update` |

## Step 4: Handle Breaking Changes

For each dependency with a breaking major version change:

1. **Update the version constraint** in the manifest file.
2. **Find the changelog or upgrade guide:**
   - **Elixir**: `https://hexdocs.pm/{package}/changelog.html`, or the package's GitHub releases
   - **Node**: `https://github.com/{owner}/{repo}/releases` or `CHANGELOG.md` in the repo, or `https://www.npmjs.com/package/{package}?activeTab=versions`
   - **Python**: `https://pypi.org/project/{package}/#history`, or the project's GitHub releases/changelog
   - **Rust**: `https://crates.io/crates/{crate}` -> Repository link -> CHANGELOG or releases
   - **Go**: Module docs or GitHub releases
   - **Ruby**: `https://rubygems.org/gems/{gem}` -> changelog link
3. **Read the breaking changes** between the current and target versions.
4. **Delegate necessary code modifications through `my-implement`.** Supply one
   bounded behavioral slice with an honest RED test, the affected paths, and
   upgrade-guide constraints; do not let a dependency update broaden into an
   unsliced refactor.
5. **Verify** (Step 5) before moving to the next breaking change.

## Step 5: Verify

Run these checks after updates. The exact commands depend on the ecosystem.

| Check | Commands by ecosystem |
|-------|----------------------|
| **Compile/build** | `mix compile --warnings-as-errors` / `npx tsc --noEmit` / `uv run python -m py_compile` / `cargo build` |
| **Format** | `mix format --check-formatted` / `npx prettier --check .` / `uv run ruff format --check` / `cargo fmt --check` |
| **Lint** | `mix credo` (if present) / `npx eslint .` / `uv run ruff check` / `cargo clippy` |
| **Test** | `mix test` / `npm test` / `uv run pytest` / `cargo test` |

Run whatever subset applies to the project. If the project has a `Makefile`, `justfile`, or scripts in `package.json`, prefer those (e.g. `make check`, `just test`, `npm run lint`).

If any check fails and the cause is obvious and bounded, invoke `my-implement`
for one repair slice before proceeding; otherwise stop for a breaking-migration
decision.

## Step 6: Summary

After all updates:

1. Re-run the outdated command to confirm everything is current.
2. Summarize what was updated, grouping by safe vs breaking.
3. Note any breaking changes that required code modifications and what was changed.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's just a patch bump, no need to check the changelog" | Patch releases can still ship behavior changes or accidental breaks — skim the changelog for anything touching code you use. |
| "The major bump only touches an area we don't use" | Confirm that by reading the diff/changelog, not by assuming — transitive usage (a re-exported type, a peer dependency) is easy to miss. |
| "I'll bundle several breaking upgrades in one pass to save time" | A bulk bump that breaks the build hides which package caused it — isolate breaking changes per package so the cause and the revert stay clean. |
| "Tests passed, so the upgrade is safe" | Tests cover behavior you wrote tests for, not new deprecation warnings, peer-dependency conflicts, or runtime-only breakage — re-run lint/build/audit too. |
| "The lockfile diff is huge, I won't review it" | A hand-edited or unreviewed lockfile diff can pull in unexpected transitive versions — skim it for anything beyond the direct bump. |
