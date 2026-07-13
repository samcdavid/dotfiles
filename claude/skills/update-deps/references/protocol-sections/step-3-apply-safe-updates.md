## Step 3: Apply Safe Updates

Run the update command for safe (non-breaking) dependencies first.

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
