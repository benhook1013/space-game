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
- Single endless level with player health and quick restart
- Local high score stored on device using `shared_preferences`
- Basic sound effects with a mute toggle
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
assets/                 # Art, sounds, etc.
lib/                    # Game source code (coming soon)
web/                    # PWA configuration
test/                   # Automated tests (placeholder)
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

## Flutter Version Management

This repo uses [FVM](https://fvm.app/) to pin the Flutter SDK version. After
cloning, run `fvm install` to download the SDK specified in `fvm_config.json`.
Use `fvm flutter` in place of the global `flutter` command when building or
running the game.

The project is released under the [MIT License](LICENSE).
