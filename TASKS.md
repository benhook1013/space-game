# ✅ Task List

Tracking immediate work to reach the MVP. See [PLAN.md](PLAN.md) and [DESIGN.md](DESIGN.md)
for context, and milestone docs (`milestone-*.md`) for detailed goals.

## Setup ([milestone-setup.md](milestone-setup.md))

- [x] Install FVM and fetch the pinned Flutter SDK (version `3.32.8`).
- [x] Run `fvm flutter doctor` to verify the environment.
- [x] Scaffold the Flutter project (`fvm flutter create .`) if not already.
- [x] Enable web support (`fvm flutter config --enable-web`).
- [x] Add Flame, `flame_audio` and `shared_preferences` to `pubspec.yaml`.
- [x] Run `fvm flutter pub get` to install dependencies.
- [x] Create placeholder `assets.dart` and `constants.dart` to centralise asset
  paths and tunable values.
- [x] Add a tiny `log.dart` helper that wraps `debugPrint`.
- [x] Commit generated folders (`lib/`, `web/`, etc.).
- [x] Set up GitHub Actions workflow for lint, test and web deploy.
- [x] Document placeholder assets and credits.
- [x] Create `assets_manifest.json` to list bundled assets for caching
  (see `assets_manifest.md`).

## Core Loop ([milestone-core-loop.md](milestone-core-loop.md))

- [x] Player ship moves with joystick or keyboard.
- [x] Ship can shoot and destroy a basic enemy type.
- [x] Random asteroids spawn and can be mined for score.
- [x] Destroying enemies awards score.
- [x] Game states: menu → playing → game over with restart.

## Polish ([milestone-polish.md](milestone-polish.md))

- [x] Parallax starfield renders behind gameplay.
- [x] Implement `audio_service.dart` wrapping `flame_audio` with a
      mute toggle.
- [x] Implement `storage_service.dart` using `shared_preferences`
      to persist the local high score.
- [x] Simple HUD and menus layered with Flutter overlays.

## PWA

- [x] Add `web/manifest.json` and placeholder icons for installable PWA.
- [x] Review service worker caching strategy and add custom `sw.js` for
      cache-first asset handling.

## Testing

- [x] Add unit tests for storage and audio services.

## Optimisation

- [x] Add bullet object pool to reduce allocations.

## Enhancements

- [x] Pause/resume overlay toggled via HUD and Escape key.
