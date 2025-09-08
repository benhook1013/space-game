# web/

PWA configuration and static web files.

- `manifest.json` defines PWA metadata like `start_url`, `display` and colour values.
- `icons/` holds 192x192 and 512x512 app icons.
- `index.html` bootstraps the Flutter app and registers `sw.js` after hashing
  `assets_manifest.json` so the cache version updates automatically when
  assets change.
- `sw.js` precaches core files, batches manifest assets with `cache.addAll`
  to avoid duplicate fetches, and applies a stale-while-revalidate strategy
  for static assets so visits start instantly while updates download in the
  background.
- `assets_manifest.json` is copied here from the project root so the service
  worker can fetch it at runtime. Keep both copies in sync when assets change.
- See [../PLAN.md](../PLAN.md) for PWA goals and deployment guidelines.

Build for release with:

```sh
fvm flutter build web --release
```

Use `--base-href /space-game/` when targeting GitHub Pages so asset paths
resolve correctly.
