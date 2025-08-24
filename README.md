# 🚀 Space Miner PWA

**Space Miner** is a mobile-first 2D space shooter where players fly around,
mine asteroids and blast enemies — all built with **Flutter** and **Flame**.

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
- Solo-friendly workflow with minimal tooling
- Fun, casual tone with cartoony visuals
- Modular game logic built with Flame (pinned for stability)
- Minimal dependencies to keep the project lightweight
- Simple CI/CD through GitHub Actions
- Fully open-source and remixable

---

## 🧩 MVP Features

- Touch/joystick movement and shooting
- One enemy type with collision and random spawns
- Asteroids to mine for score
- Single endless level with quick restart
- Local high score stored on device using `shared_preferences`
- Basic sound effects with a mute toggle
- Pause and resume gameplay via overlay
- Keyboard controls for desktop playtests
- Game works offline after the first load
- Parallax starfield background

## 🔮 Future Plans

- Co-op multiplayer using WebSockets (host-authoritative)
- Optional backend for saves or analytics
- Native builds (Play Store/TestFlight) if needed later
- Inventory, upgrades, menus, shop UI and save/load

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
web/                    # PWA configuration (see web/README.md)
test/                   # Automated tests (placeholder) (see test/README.md)
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

The repository does not bundle art or audio. Create the following files locally
under `assets/` before running the game:

- `assets/images/player.png`
- `assets/images/enemy.png`
- `assets/images/asteroid.png`
- `assets/images/bullet.png`
- `assets/audio/shoot.wav`

Simple placeholders can be generated with common tools. For example:

- ImageMagick: `convert -size 32x32 canvas:red assets/images/player.png`
- FFmpeg: `ffmpeg -f lavfi -i "sine=frequency=880:duration=0.1" assets/audio/shoot.wav`

Remember to update `assets_manifest.json` and credit any third-party assets in
`ASSET_CREDITS.md`.

---

## Flutter Tooling

Run `./setup.sh` after cloning to download the pinned Flutter SDK into
`.tooling/flutter`, install the FVM and Markdown tooling, and add pub global
binaries to your `PATH`. The repository provides wrapper scripts for both
Unix-like shells and Windows, which bootstrap this SDK on demand and then
delegate to the real `flutter` and `dart` binaries:

- Unix shells: `scripts/flutterw`, `scripts/dartw`
- PowerShell: `scripts\flutterw.ps1`, `scripts\dartw.ps1`
- Command Prompt: `scripts\flutterw.cmd`, `scripts\dartw.cmd`

To override the default Flutter version, set `FLUTTER_VERSION` before running a
wrapper. Example:

```powershell
$env:FLUTTER_VERSION='3.32.8'; scripts\bootstrap_flutter.ps1 -Force
```

Use `-Force` to re-download the SDK or `-Quiet` to suppress progress messages.

Examples:

```bash
./scripts/flutterw --version
./scripts/dartw pub get
```

The project also includes an `fvm_config.json` for those who prefer to use
[FVM](https://fvm.app/). In that case, run `fvm install` once and then use
`fvm flutter`/`fvm dart` for subsequent commands.

The project is released under the [MIT License](LICENSE).
