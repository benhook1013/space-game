# web/

PWA configuration and static web files.

- `manifest.json` defines PWA metadata like `start_url`, `display` and theme
  colours.
- `icons/` holds 192x192 and 512x512 app icons.
- The generated `flutter_service_worker.js` enables offline caching.
- See [../PLAN.md](../PLAN.md) for PWA goals and deployment guidelines.

Build for release with:

```sh
fvm flutter build web --release
```

Use `--base-href /space-game/` when targeting GitHub Pages so asset paths
resolve correctly.
