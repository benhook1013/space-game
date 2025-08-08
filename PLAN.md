# 🚀 Space Game Development Plan

Small mobile‑first 2D shooter built with Flutter and Flame.
The goal is a lightweight PWA prototype that one developer can iterate on quickly.

## 🎯 Goals

- Offline play in the browser using Flutter + Flame.
- Installable PWA with touch controls.
- Code and asset base kept tiny and easy to maintain.
- Ship quickly and iterate in small increments.

## 🚫 Non‑Goals

- Analytics, accounts or other backend services.
- Multiplayer or native builds (future work).
- Large asset pipelines or complex tooling.

## 🛠️ Setup

### Repository

- Public GitHub repo `space-game`.
- Include `README.md`, `.gitignore`, `LICENSE`, `fvm_config.json`.

### Toolchain

- `fvm install` to download the pinned Flutter SDK.
- `fvm flutter doctor` and `fvm flutter pub get`.
- Initialize with `fvm flutter create .` once ready.
- Enable web: `fvm flutter config --enable-web`.
- Run with `fvm flutter run -d chrome`.
- Pin the Flame version in `pubspec.yaml`;
  run all commands through `fvm`.

### Workflow

- Use Codespaces or any lightweight editor
  (VS Code, GitHub Mobile, Replit).
- Work directly on `main`; branch only for larger features.
- Commit small, frequent changes and push often.

## 🧾 Documentation

- `DESIGN.md` – game overview and mechanics.
- `TASKS.md` – prioritized implementation steps.
- Optional milestone docs (`milestone-1.md`, etc.).
- Keep docs short and update as features land.

## 🏗️ Architecture

- `SpaceGame` extends `FlameGame` in `lib/space_game.dart`.
- `GameWidget` hosts the game and overlays menus/HUD.
- Components live in `lib/components/`
  (`player.dart`, `enemy.dart`, `asteroid.dart`, `bullet.dart`, etc.).
- On‑screen joystick for movement and a shoot button.
- Game states:
  **menu → playing → game over** with quick restart.
- Components remain small with UUIDs and JSON‑serializable state
  for possible future multiplayer or saving.
- Favor composition over inheritance and keep dependencies minimal.

## 🎮 MVP Feature Set

- Touch/joystick movement and shooting.
- One enemy type with collision and random spawns.
- Asteroids to mine for score or pickups.
- Player health and simple game over screen.
- Local high score stored on device
  (e.g., shared preferences).
- Basic sound effects with mute toggle.

## 🎨 Assets & PWA

- Asset folders:
  - `assets/images/`
  - `assets/sfx/`
  - `assets/music/`
  - `assets/fonts/`
- Placeholder shapes or colors are fine early;
  document sources in `ASSET_GUIDE.md` and
  credit in `ASSET_CREDITS.md`.
- Provide `web/manifest.json` with:
  - `start_url` `/`
  - `display` `standalone`
  - landscape orientation
  - `background_color` `#000000`
  - `theme_color` `#0f0f0f`
- Include icons (192x192, 512x512) in `web/icons/`.
- Default `flutter_service_worker.js` handles offline caching.
- Build with `fvm flutter build web` and test with
  `fvm flutter run -d web-server`.
- Deploy the PWA via GitHub Pages (`gh-pages` branch)
  using a GitHub Actions workflow to publish `build/web`.

## ✍️ Code Style & Testing

- Format with `fvm dart format .`.
- Analyze with `fvm flutter analyze`.
- Lint docs with `markdownlint`.
- Manual testing only for now.
- Use `PLAYTEST_CHECKLIST.md`, `MANUAL_TESTING.md`,
  and optional `playtest_logs/`.

## 🔮 Future Ideas

- **Multiplayer** (`networking.md`):
  host‑authoritative co‑op via WebSocket.
- **Backend (optional)**:
  local storage sync or Firebase.
- **Native deployment (optional)**:
  Codemagic, Play Store, TestFlight.
- Additional features:
  inventory, upgrades, HUD, menus (main/pause),
  shop UI, sound, save/load.

## 🔁 Daily Loop

```text
1. Edit code or docs.
2. Push to GitHub.
3. CI builds the PWA.
4. Test on device and install via "Add to Home Screen".
5. Log findings and next steps in `TASKS.md`.
```
