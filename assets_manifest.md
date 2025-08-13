# assets_manifest.json

Reference manifest tracking bundled asset files.

- Lists every file under `assets/` that ships with the game.
- Version the manifest per release to aid caching and PWA updates.
- Update this file whenever assets are added, removed or renamed.
- Keep entries sorted for readability.
- The build pipeline and service worker can use this list to precache assets.
- See [PLAN.md](PLAN.md) for broader context.
