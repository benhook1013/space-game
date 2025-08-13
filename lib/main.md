# main.dart

Entry point launching the Flutter app and `SpaceGame`.

## Responsibilities

- Bootstraps the Flutter app using the FVM-pinned SDK.
- Preloads assets via `Assets.load()` before gameplay.
- Wraps `SpaceGame` in a `GameWidget` so overlays can render Flutter UI.
- Ensures the PWA manifest and other web configuration are loaded before play.
- Serves as a thin launcher; game logic lives in `SpaceGame` and components.

See [../PLAN.md](../PLAN.md) for the authoritative roadmap.
