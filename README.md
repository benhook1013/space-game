# 🚀 Space Miner PWA

**Space Miner** is a mobile-first 2D space miner where players hunt for
asteroids to harvest minerals while fending off periodic enemy waves — all
built with **Flutter** and **Flame**. The ship sports an auto-firing mining
laser for rocks and a main cannon that locks onto the closest threat.

The aim is a light-hearted, cartoony game that runs smoothly on both mobile and
desktop browsers using **Progressive Web App (PWA)** technology. You can
install it straight from your browser and play offline with no app store
required.

Multiplayer is planned as a simple host-authoritative co-op mode where one
player simulates the world and others connect over the local network — no
dedicated server or NAT traversal.

---

## 🎯 Project Goals

- Offline play in the browser using Flutter + Flame
- Installable PWA with touch controls
- Code and asset base kept tiny and easy to maintain
- Ship quickly and iterate in small increments
- Responsive scaling for phones, tablets and desktop
- Static dark colour palette
- Solo-friendly workflow with minimal tooling
- Fun, casual tone with cartoony visuals
- Modular game logic built with Flame (pinned for stability)
- Minimal dependencies to keep the project lightweight
- Simple CI/CD through GitHub Actions
- Fully open-source and remixable

---

## 🧩 MVP Features

- Touch/joystick movement and shooting
- Enemy groups spawn periodically and the main weapon smoothly auto-aims at the
  closest foe
- Asteroids can be mined for mineral pickups using an auto-targeting laser;
  each hit drops a mineral nearby
- A blue Tractor Aura draws nearby pickups toward the ship
- Single endless level with quick restart
- Player score, health and minerals displayed in the HUD; health drops on
  collision and minerals increase when collecting pickups from mined asteroids
- Toggable top-left minimap shows the player's heading and nearby asteroids,
  enemies and pickups
- HUD button or `B` key toggles coloured range rings showing targeting, Tractor Aura and mining radii
- Upgrades overlay lets you buy simple upgrades with minerals that persist
  between sessions, accessible via a HUD button or the `U` key. Current
  upgrades include a faster cannon, quicker mining pulses, a targeting
  computer, a Tractor Booster and Engine Tuning for higher speed
- Settings overlay adjusts volume, HUD, minimap, text and joystick scales,
  gameplay ranges and starfield tile size, and includes a reset button;
  accessible via HUD button or `O` key
- Menu allows choosing between multiple ship sprites and remembers the selection
- Local high score stored on device using `shared_preferences`
- Basic sound effects with a mute toggle on menu, HUD and game over
  screens, plus an `M` key shortcut
- Pause or resume via keyboard or HUD button with a `PAUSED` indicator and a
  hint to press `Esc` or `P` to resume, leaving the interface visible
- Keyboard controls for desktop playtests (`WASD`/arrow keys to move, `Space` to
  shoot, `Escape` or `P` to pause or resume, `M` to mute, `B` toggles range
  rings, `N` toggles the minimap, `F1` toggles debug overlays with an FPS counter
  and starfield tile outlines, `Enter` starts
  or restarts from the menu or game over, `R` restarts at any time, `Q` returns
  to the menu from pause or game over, `H` shows a help overlay that `Esc` also
  closes, `U` opens an upgrades overlay that `Esc` also closes, `O` opens the
  settings overlay)
- Game works offline after the first load
- Deterministic world-space starfield replaces the parallax background:
  - Stars spawn per chunk via Poisson-disk sampling seeded by chunk coordinates.
  - Simplex noise modulates density for subtle clusters.
  - Layered parallax with independent density multipliers and twinkle speeds adds depth.
  - Weighted radius/brightness spread (≈80% tiny, 19% small, 1% medium) with optional
    colour jitter adds variation.
  - Each chunk pre-renders to a cached `Picture`, dropping tiles outside a small
    margin around the camera, then draws with a translation of `-playerPosition`
    so the player flies over a static field. Draw faint stars first for smoother
    blending. A `debugDrawTiles` flag can outline tiles during development.
  - Tile size can be tuned in the settings overlay to balance detail and performance.

## 🔮 Future Plans

- Co-op multiplayer using WebSockets (host-authoritative)
- Optional backend for saves or analytics
- Native builds (Play Store/TestFlight) if needed later
- Inventory, mineral-based upgrades, menus, shop UI and save/load
- Optional nebula or distant galaxy overlays to enrich the starfield without
  altering its tile system

---

## 📁 Project Structure

```text
assets/                 # Art, sound, music (see assets/README.md)
lib/                    # Game source code
  main.dart             # App entry launching SpaceGame
  game/                 # FlameGame subclass & systems (see lib/game/README.md)
  components/           # Game entities (see lib/components/README.md)
  ui/                   # Flutter overlays & HUD (see lib/ui/README.md)
  assets.dart           # Central asset registry
  constants.dart        # Tunable values for balancing
  log.dart              # Tiny log() wrapper around debugPrint
  services/             # Optional helpers (see lib/services/README.md)
  theme/                # Game-specific color extensions
  util/                 # Shared helpers (object pools, spatial grid)
web/                    # PWA configuration (see web/README.md)
test/                   # Automated tests for services and game logic (see test/README.md)
assets_manifest.json    # List of bundled asset files for caching (see assets_manifest.md)
.github/workflows/      # CI and deployment scripts
PLAN.md                 # High-level plan and architecture
ASSET_GUIDE.md          # Asset format guidelines
ASSET_CREDITS.md        # License/credit info
MANUAL_TESTING.md       # Manual testing strategy
PLAYTEST_CHECKLIST.md   # Regression checklist
playtest_logs/          # Logs from manual play sessions
```

Further docs include `DESIGN.md` for architecture, `TASKS.md` for the backlog,
`milestone-setup.md`, `milestone-core-loop.md` and `milestone-polish.md` for
milestone goals, and `networking.md` for future multiplayer plans. See
[PLAN.md](PLAN.md) for the full roadmap.

---

## Asset Setup

The repository includes placeholder sprites for players, enemies and asteroids.
Create the remaining assets locally under `assets/` before running the game:

- Player sprites in `assets/images/players/` (e.g., `player1.png`)
- Enemy sprites in `assets/images/enemies/`
- Asteroid sprites in `assets/images/asteroids/`
- `assets/images/bullet.png`

Simple placeholders can be generated with common tools. For example:

- ImageMagick: `convert -size 32x32 canvas:red assets/images/enemies/faction1/unit.png`

Remember to update `assets_manifest.json` and credit any third-party assets in
`ASSET_CREDITS.md`.

---

## Flutter Tooling

Run `./setup.sh` (Unix) or `.\\setup.ps1` (PowerShell) after cloning to
download the pinned Flutter SDK into `.tooling/flutter`. Wrapper scripts in
`scripts/` use this SDK automatically:

- Unix shells: `scripts/flutterw`, `scripts/dartw`
- PowerShell: `scripts\\flutterw.ps1`, `scripts\\dartw.ps1`
- Command Prompt: `scripts\\flutterw.cmd`, `scripts\\dartw.cmd`

Examples:

```bash
./scripts/flutterw --version
./scripts/dartw pub get
./scripts/flutterw run -d web-server
```

The repo also includes an `fvm_config.json` for those who prefer
[FVM](https://fvm.app/); run `fvm install` once and then use
`fvm flutter`/`fvm dart` for subsequent commands.

Android or desktop toolchains aren’t required for PWA development. If you need
native targets, install those toolchains separately.

For Markdown linting, run:

```bash
npx --yes markdownlint-cli '**/*.md'
```

## 🌐 GitHub Pages Deployment

Pushes to `main` and `develop` trigger the [deploy workflow](.github/workflows/deploy.yml),
which builds the web release and publishes it to GitHub Pages.

- Commits on `main` update the `gh-pages` branch and appear at
  `https://benhook1013.github.io/space-game/`.
- Commits on `develop` publish to `gh-pages-staging` for preview at
  `https://benhook1013.github.io/space-game-staging/`.

When building locally for GitHub Pages, run:

```bash
fvm flutter build web --release --base-href /space-game/
```

Serve the generated `build/web` directory with any static file server (for example
`python3 -m http.server`) to preview the site before pushing.

The project is released under the [MIT License](LICENSE).
