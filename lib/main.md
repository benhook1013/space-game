# main.dart

Entry point launching the Flutter app and `SpaceGame`.

## Responsibilities

- Bootstraps the Flutter app using the FVM-pinned SDK.
- Preloads assets via `Assets.load()` before gameplay.
- Creates core services (`StorageService`, `AudioService`, `SettingsService`).
- Configures light and dark `ColorScheme`s based on the selected theme.
- Attaches global text scaling via `GameText.attachTextScale`.
- Wraps `SpaceGame` in a `GameWidget` so overlays can render Flutter UI and
  registers overlay builders for menus, HUD and dialogs.
- Observes app lifecycle changes to pause the engine and audio when unfocused.
- Ensures the PWA manifest and other web configuration are loaded before play.
- Serves as a thin launcher; game logic lives in `SpaceGame` and components.

See [../PLAN.md](../PLAN.md) for the authoritative roadmap.
