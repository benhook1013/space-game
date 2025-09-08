# assets.dart

Central asset registry for sprites, audio and fonts.

- Exposes typed getters for each asset.
- `loadEssential()` preloads only the assets needed for the menu/first level.
- `loadRemaining()` fetches the rest (including audio) asynchronously after
  the first user input.
- Gameplay code accesses assets only through this registry; no hard-coded file
  paths.
- Keeping all keys in one place simplifies refactors and avoids typos.

See [../PLAN.md](../PLAN.md) for broader context.
