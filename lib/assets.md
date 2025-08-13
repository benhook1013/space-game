# assets.dart

Central asset registry for sprites, audio and fonts.

- Exposes typed getters for each asset.
- Provides a `Future<void> load()` helper to preload required assets at game start.
- Gameplay code accesses assets only through this registry; no hard-coded file paths.
- Keeping all keys in one place simplifies refactors and avoids typos.

See [../PLAN.md](../PLAN.md) for broader context.
