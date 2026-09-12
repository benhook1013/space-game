# 🚀 Space Miner Plan

Tiny mobile‑first 2D space miner built with Flutter and Flame. Players harvest
minerals from asteroids while periodic enemy waves keep the action moving.
Target is an offline PWA that a solo developer can iterate on quickly.
See [DESIGN.md](DESIGN.md) for architecture details. The existing MVP milestones
are historical implementation checklists, not evidence of current build quality.
[WORKFLOW.md](WORKFLOW.md) defines development and handoffs;
[decisions](docs/development/DECISIONS.md) separate accepted direction from
proposals, and [TASKS.md](TASKS.md) puts the current round queue first.

## 🎯 Goals

- Offline play in the browser using Flutter + Flame
- Installable PWA with touch controls
- Code and asset base kept tiny and easy to maintain
- Ship quickly and iterate in small increments
- Responsive scaling so the same build works on phones, tablets and desktop
- Static dark colour palette; no runtime theme switching
- Solo-friendly workflow with minimal tooling
- Core loop focused on mining asteroids for minerals while fending off enemy
  groups
- Auto-firing mining laser targets asteroids while the main cannon locks onto
  the closest enemy
- A blue Tractor Aura around the ship pulls in nearby pickups
- Minerals feed a broad upgrade tree for weapons and ship systems in later
  milestones

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
- `pubspec.yaml` and the Flutter source scaffold are already committed
- Do not recreate the scaffold during routine setup; validate the existing source
- Include a barebones `pubspec.yaml` with pinned `flame`, `flame_audio`, and
  `shared_preferences` versions
- `AGENTS.md` captures coding and architecture guidelines
- Commit `pubspec.lock` so dependency versions stay consistent
- Add a minimal GitHub Actions workflow that lints, tests and deploys the web
  build; avoid complex pipelines until needed

### Flutter & FVM

Use `scripts/flutterw` and `scripts/dartw` from the project root for the pinned
Flutter `3.32.8` SDK. FVM remains an optional equivalent; do not switch versions
as a side effect of a feature round. The scaffold is already committed, so do
not run `flutter create .` as routine setup.

Read [environment notes](docs/development/ENVIRONMENT.md) before bootstrapping.
An uploaded SDK does not prove dependency resolution, tests or browser access.
Use [the WSL guide](docs/development/WSL.md) for the explicit validation commands.

## 🔁 Workflow

Follow [WORKFLOW.md](WORKFLOW.md): start from accepted source, implement one
bounded outcome, validate, deliver a verified binary patch and recovery snapshot,
then review on a branch targeting `main`. Ben or his integration agent runs
unavailable Flutter checks and returns accepted source plus playtest evidence.
Do not commit directly to `main` by default or publish before required checks.

The next priority after the process handoff is bounded PWA cache safety, followed
by opening gameplay, enemy differentiation, feedback and upgrade decisions.
Additional background systems are deferred. A finite expedition/contract mode
remains a proposal, not an approved replacement for endless play.

## 📂 Structure & Docs

- `lib/` – source code
  - `main.dart` – entry point launching `SpaceGame`
  - `game/` – `FlameGame` subclass and core systems
  - `components/` – game entities/components
  - `ui/` – Flutter widgets for menus/HUD
  - `assets.dart` – central asset registry that preloads sprites, audio and fonts
  - `constants.dart` – central place for tunable values
  - `log.dart` – tiny `log()` helper wrapping `debugPrint`
  - `ui/game_text.dart` – text widget applying global scaling for consistent style
  - `services/` – storage, audio, settings and other helpers added only when needed
  - `theme/` – `GameColors` extension with game-specific colour values
  - `util/` – shared helpers like object pools and spatial queries
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
- An `EnemySpawner` emits groups on a timer, and the player mounts an auto-fire
  mining laser plus a primary cannon that targets the nearest enemy.
- On‑screen joystick and shoot button; WASD + Space mirror touch controls
- Use Flame's built-in `JoystickComponent` and `ButtonComponent` for touch input
- Keyboard support comes from `KeyboardListenerComponent`
- States: **menu → playing → paused → game over** with quick restart or
  return to menu
- Use a `GameState` enum to manage transitions
- Centralize asset paths in an `Assets` helper that preloads sprites, audio and
  fonts so gameplay code never references file paths directly
- Favor small composable components over inheritance
- Components that need to access the game should mix in
  `HasGameReference<SpaceGame>` instead of using global singletons
- Keep Flutter UI widgets separate from game state updates
- If saving is needed later, add IDs and JSON‑serializable state
  - Camera follows the player via `CameraComponent` with no world bounds,
    and the deterministic world-space starfield spans chunks to avoid blank space
- Use `HasCollisionDetection` for collisions with simple `CircleHitbox`/`RectangleHitbox`
  shapes and a timer-based spawner
- Top‑down view with a deterministic world-space starfield generated per chunk
  via Poisson-disk sampling seeded by chunk coordinates. Low-frequency Simplex
  noise modulates density for clusters, and each chunk pre-renders to a cached
  `Picture` that sorts stars by radius so faint ones draw first for smoother
  blending. A weighted size/brightness distribution with subtle colour jitter
  adds variety, and layered parallax with gentle alpha twinkling adds depth.
  - Optional nebula or distant galaxy overlays may render above this starfield to
    enrich the backdrop without altering the tile-based generation.
    - `NebulaLayer` renders noise-generated sprites per tile using the existing
      cache worker and exposes brightness/density sliders.
    - `GalaxyLayer` draws a low-resolution bitmap with subtle parallax and
      optional tint.
    - Each layer is an independent component so work can land incrementally.
    - Both layers toggle via the settings menu and respect debug mode flags.
- Aim for 60 FPS and avoid heavy per‑frame allocations
- For frequently spawned objects, bullets, asteroids and enemies use simple
  object pools to reduce garbage collection overhead
- A lightweight `GameEventBus` emits component spawn and remove events so
  systems like the targeting service and pool manager can react without
  direct references
- `PoolManager` owns these pools and keeps a spatial grid of asteroids for
  efficient proximity queries
- Movement and animations should be time‑based using `dt` to stay consistent
  across frame rates
- Rely on Flame's `update`/`render` lifecycle; avoid custom game loops

## 🎮 MVP

- Touch/joystick movement and shooting
- Shooting uses a short cooldown to limit fire rate
- Enemy groups spawn periodically; the main weapon smoothly auto-aims at the closest foe
- Asteroids drop mineral pickups when mined with an auto-targeting laser;
  destroying enemies also grants points
- A blue Tractor Aura around the ship pulls in nearby pickups
- Single endless level without progression for now
- Player score, minerals and health shown in the HUD with simple
  start/game‑over screens
- Toggable top-left minimap shows the player's heading and nearby asteroids,
  enemies and pickups
- HUD button or `B` key toggles coloured range rings showing targeting, Tractor Aura and mining radii
- Local high score stored on device (e.g., shared preferences)
- Menu offers a reset button to clear the high score
- Menu allows choosing between multiple ship sprites and remembers the selection
- Basic sound effects using `flame_audio` with mute toggle (button or `M` key)
  available on menu, HUD and game over overlays
- Keyboard controls for desktop playtests (`WASD`/arrow keys to move, `Space` to
  shoot, `Escape` or `P` to pause or resume, `M` to mute, `N` toggles the
  minimap, `F1` toggles debug overlays with an FPS counter and outlines starfield
  tiles, `Enter`
  starts or restarts from the menu or game over, `R` restarts at any time, `H`
  shows a help overlay that `Esc` also closes, `U` opens an upgrades overlay
  that `Esc` also closes, `O` opens the settings overlay, `B` toggles range rings)
- Upgrades overlay lets players spend minerals on simple upgrades that
  persist between sessions, opened with a HUD button or the `U` key and
  pausing gameplay. Available upgrades cover fire rate, mining speed,
  targeting and Tractor Aura ranges, an Engine Tuning option for faster
  movement and a Shield Booster that slowly regenerates health
- Settings overlay with master volume slider and sliders for HUD, minimap,
  text, joystick, targeting, Tractor Aura and mining ranges, starfield tile
  size, plus a reset button, accessible via HUD button or `O` key
- Game works offline after the first load thanks to the service worker
- Deterministic world-space starfield replaces the parallax background:
  - Stars spawn per chunk via Poisson-disk sampling seeded by chunk coordinates.
  - Simplex noise modulates density for subtle clusters.
  - Layered parallax with independent density multipliers and twinkle speeds adds depth.
  - Weighted size/brightness spread (≈80% tiny, 19% small, 1% medium) with optional
    colour jitter adds variety.
  - Each chunk pre-renders to a cached `Picture`, dropping tiles outside a small
    margin around the camera, then draws with a translation of `-playerPosition`
    so the player flies over a static backdrop. Stars sort by radius so faint
    ones render first for smoother blending. A `debugDrawTiles` option outlines
    tile boundaries when debug mode (`F1`) is active to aid development, and an
    FPS counter is displayed.
  - Tile size can be tuned in the settings overlay to balance detail and performance.
- Pause or resume with a `PAUSED` overlay prompting players to press `Esc` or
  `P` to resume; `Q` returns to the menu from pause or game over

## 🗓️ Milestones

- **Setup** – basic project scaffolding runs in the browser with placeholder assets
- **Core Loop** – player moves and shoots, one enemy type, basic scoring
- **Polish** – deterministic world-space starfield, sound effects, and local high score

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
- Lint docs with `npx markdownlint-cli '**/*.md'`
- Run tests with `scripts/flutterw test` (auto-detects CPU cores for `--concurrency`)
- Use `flutter_test` for widget tests and `flame_test` for component/system tests
  once tests are added
- Cover object pools with unit tests to ensure instances are reused
- Manual testing for now; automate later under `test/`
- Use `PLAYTEST_CHECKLIST.md`, `MANUAL_TESTING.md`, and optional `playtest_logs/`
- Follow `AGENTS.md` conventions when contributing
- Enable Flame's debug mode in dev builds to show bounding boxes and FPS;
  toggle at runtime with the `F1` key
- Add a tiny `log()` helper around `debugPrint` so messages can be silenced in release

## 🌌 World Exploration

The current build uses a single-screen play area. To let players roam, expand
the world beyond the viewport and have the camera track the ship.

- Treat space as effectively infinite; avoid hard world bounds.
- Attach a `CameraComponent` that follows the player without clamping.
- Continuously spawn asteroids, enemies and pickups ahead of the ship and
  despawn any far behind to keep the scene light.
- Generate and cache stars per world-space chunk so no gaps appear as the camera moves.
- A small togglable minimap in the top-left aids navigation through the endless world.

## 🔮 Future Ideas

- **Multiplayer** (`networking.md`): host‑authoritative co‑op via WebSocket
- **Backend (optional)**: local storage sync or Firebase
- **Native deployment (optional)**: Codemagic, Play Store, TestFlight
- Additional features: inventory, extensive mineral-based upgrade tree for
  weapons and ship systems, HUD, menus, shop UI, save/load

## 🔁 Daily Loop

```text
1. Read the current decisions, environment notes, round log and accepted source
2. Implement one bounded change with relevant tests, assets and docs
3. Run available checks and verify a binary patch against an untouched baseline
4. Apply on a review branch; validate in WSL/CI and playtest when relevant
5. Review and merge to main through repository rules
6. Return accepted source, validation logs and playtest observations
```
