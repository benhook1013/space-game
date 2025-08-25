# web/

PWA configuration and static web files.

- `manifest.json` defines PWA metadata like `start_url`, `display` and theme
  colours.
- `icons/` holds 192x192 and 512x512 app icons.
- `index.html` bootstraps the Flutter app; the generated
  `flutter_service_worker.js` handles caching.
- See [../PLAN.md](../PLAN.md) for PWA goals and deployment guidelines.

Build for release with:

```sh
fvm flutter build web --release
```

Ensure `index.html` contains `<base href="$FLUTTER_BASE_HREF">`. Then build with
`--base-href /space-game/` when targeting GitHub Pages so asset paths resolve
correctly.
