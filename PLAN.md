# 🚀 Space Game Plan

Tiny mobile‑first 2D shooter built with Flutter and Flame.
Target is an offline PWA that a solo developer can iterate on quickly.

## 🎯 Goals

- Offline play in the browser using Flutter + Flame
- Installable PWA with touch controls
- Code and asset base kept tiny and easy to maintain
- Ship quickly and iterate in small increments

## 🚫 Non‑Goals

- Analytics, accounts or other backend services
- Multiplayer or native builds (future work)
- Large asset pipelines or complex tooling

## 🧭 Design Principles

- Keep the entire project understandable by one person
- Prefer built‑in Flame and Flutter features over custom frameworks
- Optimize for quick iteration and avoid unnecessary abstraction

## 🛠️ Setup

### Repository

- Public GitHub repo `space-game`
- Contains `README.md`, `.gitignore`, `LICENSE`,
  `pubspec.yaml`, `.analysis_options.yaml`, `fvm_config.json`

### Flutter & FVM

- `fvm install` then `fvm use` to fetch and activate the pinned Flutter SDK
- Flutter version is defined in `fvm_config.json` (currently `3.32.8`)
- `fvm flutter doctor` then `fvm flutter pub get`
- Enable web: `fvm flutter config --enable-web`
- Run with `fvm flutter run -d chrome` for debug or `-d web-server` for PWA tests
- Pin the Flame version in `pubspec.yaml`; always use `fvm` commands

## 🔁 Workflow

- Use Codespaces or any lightweight editor (VS Code, GitHub Mobile, Replit)
- Work directly on `main`; branch only for larger features
- Commit small, frequent changes with messages like `feat:`, `fix:`, `docs:`

## 📂 Structure & Docs

- `lib/` – game code
- `assets/` – images, audio and fonts
- `web/` – PWA manifest, icons and service worker
- `test/` – placeholder for future automated tests
- `pubspec.yaml` – dependencies and asset declarations
- `.gitignore` – ignore `build/`, `.dart_tool/` and other generated files
- `.analysis_options.yaml` – enable `flutter_lints` rules
- `lib/main.dart` – entry point launching `SpaceGame`
- Root Markdown files for planning, playtests and asset credits
  (`PLAN.md`, `PLAYTEST_CHECKLIST.md`, `MANUAL_TESTING.md`, `playtest_logs/`)
- `DESIGN.md` for mechanics, `TASKS.md` for backlog, optional `milestone-*.md`

## 🏗️ Architecture

- `SpaceGame` extends `FlameGame` in `lib/space_game.dart`
- `GameWidget` hosts the game and overlays menus/HUD
- Components live in `lib/components/`
  (`player.dart`, `enemy.dart`, `asteroid.dart`, `bullet.dart`…)
- On‑screen joystick and shoot button; WASD + Space mirror touch controls
- States: **menu → playing → game over** with quick restart
- Use a `GameState` enum to manage transitions
- Centralize asset paths in an `Assets` helper that preloads sprites, audio and fonts
  so gameplay code never references file paths directly
- Favor small composable components over inheritance
- If saving is needed later, add IDs and JSON‑serializable state
- Fixed logical resolution scaled to device for consistent gameplay
- Camera follows the player via `CameraComponent` with a fixed resolution viewport
- `HasCollisionDetection` for collisions; `SpawnController` for spawns
- Top‑down view with a simple parallax starfield background
- Aim for 60 FPS and avoid heavy per‑frame allocations
- Movement and animations should be time‑based using `dt` to stay consistent
  across frame rates

## 🎮 MVP

- Touch/joystick movement and shooting
- One enemy type with collision and random spawns
- Asteroids to mine for score or pickups
- Player health and simple start/game‑over screens
- Local high score stored on device (e.g., shared preferences)
- Basic sound effects using `flame_audio` with mute toggle
- Keyboard controls for desktop playtests
- Simple parallax starfield background

## 🎨 Assets & PWA

### Assets

- `assets/images/`, `assets/audio/`, `assets/fonts/`
- Placeholder shapes or colors are fine early;
  document sources in `ASSET_GUIDE.md` and credit in `ASSET_CREDITS.md`
- Prefer CC0 or similar licenses and keep total assets <5 MB

### PWA & Deployment

- `web/manifest.json` with:
  - `start_url` `/`
  - `display` `standalone`
  - landscape orientation
  - `background_color` `#000000`
  - `theme_color` `#0f0f0f`
- Icons 192x192 and 512x512 in `web/icons/`
- Default `flutter_service_worker.js` for offline caching
- Build with `fvm flutter build web --release`
- Test with `fvm flutter run -d web-server`
- Deploy via GitHub Pages (`gh-pages`) using a GitHub Actions workflow  
  to publish `build/web`

## ✍️ Style & Testing

- Format with `fvm dart format .`
- Analyze with `fvm flutter analyze` (guided by `.analysis_options.yaml`)
- Lint docs with `npx markdownlint *.md`
- Once tests exist, run `fvm flutter test`
- Manual testing for now; automate later under `test/`
- Use `PLAYTEST_CHECKLIST.md`, `MANUAL_TESTING.md`, and optional `playtest_logs/`
- Enable Flame's debug mode in dev builds to show bounding boxes and FPS

## 🔮 Future Ideas

- **Multiplayer** (`networking.md`): host‑authoritative co‑op via WebSocket
- **Backend (optional)**: local storage sync or Firebase
- **Native deployment (optional)**: Codemagic, Play Store, TestFlight
- Additional features: inventory, upgrades, HUD, menus, shop UI, sound, save/load

## 🔁 Daily Loop

```text
1. Edit code or docs
2. Push to GitHub
3. CI builds the PWA
4. Test on device and install via "Add to Home Screen"
5. Log findings and next steps in `TASKS.md`
```
