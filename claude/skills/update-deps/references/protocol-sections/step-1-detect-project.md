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
