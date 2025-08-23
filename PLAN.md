# 🚀 Space Miner Plan

Tiny mobile‑first 2D shooter built with Flutter and Flame.
Target is an offline PWA that a solo developer can iterate on quickly.
See [DESIGN.md](DESIGN.md) for architecture details. All design docs are now
in sync, and tasks are broken down in the milestone docs and consolidated in
[TASKS.md](TASKS.md) so we can start coding.

## 🎯 Goals

- Offline play in the browser using Flutter + Flame
- Installable PWA with touch controls
- Code and asset base kept tiny and easy to maintain
- Ship quickly and iterate in small increments
- Responsive scaling so the same build works on phones, tablets and desktop
- Solo-friendly workflow with minimal tooling

## 🚫 Non‑Goals

- Analytics, accounts or other backend services
- Multiplayer or native builds (future work)
- Large asset pipelines or complex tooling

## 🧭 Design Principles

- Keep the entire project understandable by one person
- Prefer built‑in Flame and Flutter features over custom frameworks
- Optimize for quick iteration and avoid unnecessary abstraction
- Keep dependencies minimal—stick to core Flutter, Flame, and a few small plugins
- Build only the features needed for the current milestone;
  defer extras until they are actually required
- Favor readability over micro‑optimisation so future maintenance stays simple
- Avoid code generation or heavy frameworks so builds stay fast and debugging
  remains straightforward
- Collect tunable values (speeds, spawn rates, etc.) in a small `constants.dart`
  so balancing is easy and numbers aren't scattered across files
- Prefer composition over inheritance when adding behaviours
- Pass dependencies through constructors where possible; keep singletons rare
- Use simple state handling (plain classes or `ValueNotifier`s) instead of
  heavyweight patterns like BLoC or Redux

## 🛠️ Setup

### Repository

- Public GitHub repo `space-game`
- Contains `README.md`, `.gitignore`, `LICENSE`, `AGENTS.md`, `fvm_config.json`,
  `.analysis_options.yaml`
- `pubspec.yaml` and Flutter source folders are generated after running
  `fvm flutter create .`
- Commit the generated Flutter skeleton so a fresh clone builds immediately
- Include a barebones `pubspec.yaml` with pinned `flame`, `flame_audio`, and
  `shared_preferences` versions
- `AGENTS.md` captures coding and architecture guidelines
- Commit `pubspec.lock` so dependency versions stay consistent
- Add a minimal GitHub Actions workflow that lints, tests and deploys the web
  build; avoid complex pipelines until needed

### Flutter & FVM

- FVM manages its own Flutter and Dart SDK; no separate Dart install required
- Install FVM if needed: `dart pub global activate fvm`
- `fvm install` then `fvm use` to fetch and activate the pinned Flutter SDK
- Run `fvm flutter create .` once to scaffold the Flutter project
  if the skeleton isn't already committed
- Flutter version is defined in `fvm_config.json` (currently `3.32.8`)
- `fvm flutter doctor` then `fvm flutter pub get`
- Enable web: `fvm flutter config --enable-web`
- Run with `fvm flutter run -d chrome` for debug or `-d web-server` for PWA tests
- Pin the Flame version in `pubspec.yaml`; always use `fvm` commands

## 🔁 Workflow

- Use Codespaces or any lightweight editor (VS Code, GitHub Mobile, Replit)
- Work directly on `main`; branch only for larger features
- Commit small, frequent changes with messages like `feat:`, `fix:`, `docs:`
- Track to‑dos in a simple `TASKS.md` to keep solo development focused
- Run `fvm dart format .` and `fvm dart analyze` before committing
- After editing docs, run `npx markdownlint '**/*.md'` to keep Markdown tidy

## 📂 Structure & Docs

- `lib/` – source code
  - `main.dart` – entry point launching `SpaceGame`
  - `game/` – `FlameGame` subclass and core systems
  - `components/` – game entities/components
  - `ui/` – Flutter widgets for menus/HUD
  - `assets.dart` – central asset registry that preloads sprites, audio and fonts
  - `constants.dart` – central place for tunable values
  - `log.dart` – tiny `log()` helper wrapping `debugPrint`
  - `services/` – optional helpers such as storage or audio, added only when needed
- `assets/` – images, audio and fonts
- `web/` – PWA manifest, icons and service worker
- `test/` – placeholder for future automated tests
- `pubspec.yaml` – dependencies and asset declarations
- `.gitignore` – ignore `build/`, `.dart_tool/` and other generated files
- `.analysis_options.yaml` – enable `flutter_lints` rules
- Root Markdown docs: `AGENTS.md`, `PLAN.md`, `PLAYTEST_CHECKLIST.md`,
  `MANUAL_TESTING.md`, `ASSET_GUIDE.md`, `ASSET_CREDITS.md`, `playtest_logs/`,
  plus optional `DESIGN.md`, `TASKS.md`, `milestone-*.md`
- Each of `lib/`, `assets/`, `web/` and `test/` includes a `README.md`
  describing its contents, with additional design notes in
  `lib/main.md`, `lib/assets.md`, `lib/constants.md` and `lib/log.md`
- Keep `README.md` and other docs updated as features change and remove any
  stale sections

## 🏗️ Architecture

- `SpaceGame` extends `FlameGame` in `lib/game/space_game.dart`
- `GameWidget` hosts the game and overlays menus/HUD
- Use Flame overlays (`overlays` map) for menu and game-over screens so UI code
  stays separate from the game loop
- Components live in `lib/components/`
  (`player.dart`, `enemy.dart`, `asteroid.dart`, `bullet.dart`…)
- Keep the core `SpaceGame` lean by delegating logic to small helper classes
- On‑screen joystick and shoot button; WASD + Space mirror touch controls
- Use Flame's built-in `JoystickComponent` and `ButtonComponent` for touch input
- Keyboard support comes from `KeyboardListenerComponent`
- States: **menu → playing → game over** with quick restart
- Use a `GameState` enum to manage transitions
- Centralize asset paths in an `Assets` helper that preloads sprites, audio and
  fonts so gameplay code never references file paths directly
- Favor small composable components over inheritance
- Components that need to access the game should mix in
  `HasGameRef<SpaceGame>` instead of using global singletons
- Keep Flutter UI widgets separate from game state updates
- If saving is needed later, add IDs and JSON‑serializable state
- Fixed logical resolution scaled to device for consistent gameplay
- Camera follows the player via `CameraComponent` and a `FixedResolutionViewport`
  for consistent scaling across devices
- Use `HasCollisionDetection` for collisions with simple `CircleHitbox`/`RectangleHitbox`
  shapes and a timer-based spawner
- Top‑down view with a simple parallax starfield background using Flame's
  `ParallaxComponent`
- Aim for 60 FPS and avoid heavy per‑frame allocations
- For frequently spawned objects (like bullets or asteroids), consider simple
  object pools to reduce garbage collection overhead
- Movement and animations should be time‑based using `dt` to stay consistent
  across frame rates
- Rely on Flame's `update`/`render` lifecycle; avoid custom game loops

## 🎮 MVP

- Touch/joystick movement and shooting
- One enemy type with collision and random spawns
- Asteroids to mine for score or pickups
- Single endless level without progression for now
- Player health and simple start/game‑over screens
- Local high score stored on device (e.g., shared preferences)
- Basic sound effects using `flame_audio` with mute toggle
- Keyboard controls for desktop playtests
- Game works offline after the first load thanks to the service worker
- Simple parallax starfield background

## 🗓️ Milestones

- **Setup** – basic project scaffolding runs in the browser with placeholder assets
- **Core Loop** – player moves and shoots, one enemy type, basic scoring
- **Polish** – starfield background, sound effects, and local high score

Detailed tasks for each milestone live in
[milestone-setup.md](milestone-setup.md),
[milestone-core-loop.md](milestone-core-loop.md) and
[milestone-polish.md](milestone-polish.md). The combined backlog is maintained
in [TASKS.md](TASKS.md).

## 🎨 Assets & PWA

### Assets

- `assets/images/`, `assets/audio/`, `assets/fonts/`
- Placeholder shapes or colors are fine early;
  document sources in `ASSET_GUIDE.md` and credit in `ASSET_CREDITS.md`
- Prefer CC0 or similar licenses and keep total assets <5 MB
- Maintain a versioned `assets_manifest.json` to track assets for each release
  and help with caching (see `assets_manifest.md`)

### PWA & Deployment

- `web/manifest.json` with:
  - `start_url` `/`
  - `display` `standalone`
  - landscape orientation
  - `background_color` `#000000`
  - `theme_color` `#0f0f0f`
- Icons 192x192 and 512x512 in `web/icons/`
- Custom `sw.js` precaches assets listed in `assets_manifest.json` and
  handles runtime caching
- Build with `fvm flutter build web --release`
- Test with `fvm flutter run -d web-server`
- Deploy via GitHub Pages (`gh-pages`) using a GitHub Actions workflow
  to publish `build/web`
- When targeting GitHub Pages, build with
  `fvm flutter build web --release --base-href /space-game/` so asset paths
  resolve correctly
- Update `web/index.html` metadata (title, description) to match the game

## ✍️ Style & Testing

- Format with `fvm dart format .`
- Analyze with `fvm dart analyze` (guided by `.analysis_options.yaml`)
- Lint docs with `npx markdownlint '**/*.md'`
- Once tests exist, run `fvm flutter test`
- Use `flutter_test` for widget tests and `flame_test` for component/system tests
  once tests are added
- Manual testing for now; automate later under `test/`
- Use `PLAYTEST_CHECKLIST.md`, `MANUAL_TESTING.md`, and optional `playtest_logs/`
- Follow `AGENTS.md` conventions when contributing
- Enable Flame's debug mode in dev builds to show bounding boxes and FPS
- Add a tiny `log()` helper around `debugPrint` so messages can be silenced in release

## 🔮 Future Ideas

- **Multiplayer** (`networking.md`): host‑authoritative co‑op via WebSocket
- **Backend (optional)**: local storage sync or Firebase
- **Native deployment (optional)**: Codemagic, Play Store, TestFlight
- Additional features: inventory, upgrades, HUD, menus, shop UI, save/load

## 🔁 Daily Loop

```text
1. Edit code or docs
2. Push to GitHub
3. CI builds the PWA
4. Test on device and install via "Add to Home Screen"
5. Log findings and next steps in `TASKS.md`; update `PLAN.md` if scope changes
```
