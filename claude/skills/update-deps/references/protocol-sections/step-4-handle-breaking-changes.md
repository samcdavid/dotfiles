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
4. **Apply necessary code modifications.**
5. **Verify** (Step 5) before moving to the next breaking change.
