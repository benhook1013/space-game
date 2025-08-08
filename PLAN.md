# 🚀 Space Game Dev Plan

Mobile‑first 2D space shooter built with **Flutter** and **Flame**. The aim is a
playable prototype that installs as a PWA on phones while keeping everything
simple enough for one developer.

---

## 🎯 Goals
- Offline shooter using Flutter + Flame.
- PWA install with touch controls.
- Code and assets kept small and easy to maintain.
- Ship quickly and iterate.

## 🚫 Non‑Goals
- Analytics, account systems, or heavy backend work.
- Multiplayer and native builds (for later).
- Complex tooling or asset pipelines.

---

## 🛠️ Project Setup

### Repository
- Public GitHub repo `space-game`.
- Include `README.md`, `.gitignore`, `LICENSE`, `fvm_config.json`.

### Toolchain
- `fvm install` to download the pinned Flutter SDK.
- `fvm flutter doctor` and `fvm flutter pub get`.
- Initialize with `fvm flutter create .` once ready.
- Enable web: `fvm flutter config --enable-web`.
- Run with `fvm flutter run -d chrome`.
- Pin the Flame version in `pubspec.yaml` and run all commands via `fvm`.

### Editors & Workflow
- Use Codespaces or a lightweight editor (VS Code, GitHub Mobile).
- Quick edits via Replit or Termux are fine.
- Work directly on `main`; branch only for larger features.

---

## 🧾 Documentation
- `DESIGN.md` – game overview and mechanics.
- `TASKS.md` – prioritized implementation steps.
- Optional milestone docs (`milestone-1.md`, …).
- Keep documents short and update as features land.

---

## 🏗️ Architecture & Game Flow
- `SpaceGame` extends `FlameGame` in `lib/space_game.dart`.
- `GameWidget` hosts the game and overlays menus/HUD.
- Components live in `lib/components/` (`player.dart`, `enemy.dart`, `asteroid.dart`, `bullet.dart`, etc.).
- On‑screen joystick for movement and a shoot button.
- Game states: **menu → playing → game over** with quick restart.
- Keep components small with UUIDs and JSON‑serializable state for future multiplayer or saving.

---

## 🎮 MVP Feature Set
- Touch/joystick movement and shooting.
- One enemy type with collision and random spawns.
- Asteroids to mine for score or pickups.
- Player health and simple game over screen.
- Local high score stored on device (e.g., shared preferences).
- Basic sound effects with mute toggle.

---

## 🎨 Assets & PWA Build
- Asset folders:
  - `assets/images/`
  - `assets/sfx/`
  - `assets/music/`
  - `assets/fonts/`
- Placeholder shapes or colors are fine early; document sources in `ASSET_GUIDE.md` and credit in `ASSET_CREDITS.md`.
- Provide `web/manifest.json` (start_url `/`, display `standalone`, landscape orientation,
  `background_color` `#000000`, `theme_color` `#0f0f0f`) and icons (192x192, 512x512) in `web/icons/`.
- Default `flutter_service_worker.js` handles offline caching.
- Build with `fvm flutter build web` and test with `fvm flutter run -d web-server`.
- Deploy the PWA via GitHub Pages (`gh-pages` branch) using a GitHub Actions workflow to publish `build/web`.

---

## ✍️ Code Style & Testing
- Use Flutter defaults:
  - `dart format`
  - `flutter analyze`
- Run tools through `fvm` (`fvm dart format .`, `fvm flutter analyze`).
- Manual testing only for now.
- Use `PLAYTEST_CHECKLIST.md`, `MANUAL_TESTING.md`, and optional `playtest_logs/`.

---

## 🔮 Future Ideas
- **Multiplayer** (`networking.md`): host‑authoritative co‑op via WebSocket.
- **Backend (optional)**: local storage sync or Firebase.
- **Native deployment (optional)**: Codemagic, Play Store, TestFlight.
- Additional features: inventory, upgrades, HUD, menus (main/pause), shop UI, sound, save/load.

---

## 🔁 Daily Loop
```text
1. Edit code or docs.
2. Push to GitHub.
3. CI builds the PWA.
4. Test on device and install via "Add to Home Screen".
5. Log findings and next steps in `TASKS.md`.
```

