# ✅ Task List

Tracking immediate work to reach the MVP. See [PLAN.md](PLAN.md) and
`milestone-*.md` for detailed goals.

## Setup

- [ ] Install FVM and fetch the pinned Flutter SDK (version `3.32.8`).
- [ ] Run `fvm flutter doctor` to verify the environment.
- [ ] Scaffold the Flutter project (`fvm flutter create .`) if not already.
- [ ] Enable web support (`fvm flutter config --enable-web`).
- [ ] Add Flame, `flame_audio` and `shared_preferences` to `pubspec.yaml`.
- [ ] Run `fvm flutter pub get` to install dependencies.
- [ ] Create placeholder `assets.dart` and `constants.dart` to centralise asset
      paths and tunable values.
- [ ] Add a tiny `log.dart` helper that wraps `debugPrint`.
- [ ] Commit generated folders (`lib/`, `web/`, etc.).
- [ ] Set up GitHub Actions workflow for lint, test and web deploy.
- [ ] Document placeholder assets and credits.
- [x] Create `assets_manifest.json` to list bundled assets for caching
  (see `assets_manifest.md`).

## Core Loop

- [ ] Player ship moves with joystick or keyboard.
- [ ] Ship can shoot and destroy a basic enemy type.
- [ ] Random asteroids spawn and can be mined for score.
- [ ] Game states: menu → playing → game over with restart.

## Polish

- [ ] Parallax starfield renders behind gameplay.
- [ ] Sound effects via `flame_audio` with mute toggle.
- [ ] Local high score using `shared_preferences`.
- [ ] Simple HUD and menus layered with Flutter.
