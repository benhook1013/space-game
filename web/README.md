# web/

PWA configuration and static web files.

- `manifest.json` defines PWA metadata like `start_url`, `display` and colour values.
- `icons/` holds 192x192 and 512x512 app icons.
- `index.html` bootstraps the Flutter app and registers `sw.js`.
- `sw.js` precaches core files, then caches optional assets from
  `assets_manifest.json` in the background and serves requests with a
  stale-while-revalidate strategy.
- `assets_manifest.json` is copied here from the project root so the service
  worker can fetch it at runtime. Keep both copies in sync when assets change.
- See [../PLAN.md](../PLAN.md) for PWA goals and deployment guidelines.

Build for release with:

```sh
fvm flutter build web --release
```

Use `--base-href /space-game/` when targeting GitHub Pages so asset paths
resolve correctly.
