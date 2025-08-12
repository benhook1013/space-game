# 🚀 Space Miner PWA

**Space Miner** is a mobile-first, Codex-assisted 2D space shooter where players
fly around, mine asteroids, blast enemies and upgrade their ship — all built
with **Flutter** and **Flame**.

The aim is a light-hearted, cartoony game that runs smoothly on both mobile and
desktop browsers using **Progressive Web App (PWA)** technology. You can
install it straight from your browser and play offline with no app store
required.

Multiplayer is planned as a simple host-authoritative co-op mode where one
player simulates the world and others connect over the local network — no
dedicated server or NAT traversal.

---

## 🎯 Project Goals

- Mobile- and desktop-friendly 2D space shooter
- Codex-generated code driven by natural language prompts
- Fully playable on iOS/Android/PC via PWA
- Fun, casual tone with cartoony visuals
- Modular game logic built with Flame (pinned for stability)
- Minimal dependencies to keep the project lightweight
- Multiplayer-ready architecture (host based, offline first)
- Simple CI/CD through GitHub Actions
- Fully open-source and remixable

---

## 🧩 Key Features (in progress)

- Player ship with rotation, thrust and shooting
- Enemies and asteroids with collisions and drops
- Ship upgrade and resource mining loop
- Offline save system (JSON or local storage)
- Planned co-op multiplayer using WebSockets
  - Simple JSON action protocol (`move`, `shoot`, `mine`, etc.)
  - QR-code or local IP connection — no lobby server needed
- PWA install support with manifest, icons and offline cache
- Optional native builds may come later (Play Store/TestFlight not planned)

---

## 📁 Project Structure

```text
assets/                 # Art, sounds, etc.
lib/                    # Game source code (coming soon)
web/                    # PWA configuration
.github/workflows/      # CI and deployment scripts
PLAN.md                 # High-level plan and architecture
ASSET_GUIDE.md          # Asset format guidelines
ASSET_CREDITS.md        # License/credit info
MANUAL_TESTING.md       # Manual testing strategy
PLAYTEST_CHECKLIST.md   # Regression checklist
playtest_logs/          # Logs from manual play sessions
```

Further docs include `DESIGN.md` for architecture, `TASKS.md` for the backlog and
`networking.md` for future multiplayer plans. See [PLAN.md](PLAN.md) for the full
roadmap.

---

## Flutter Version Management

This repo uses [FVM](https://fvm.app/) to pin the Flutter SDK version. After
cloning, run `fvm install` to download the SDK specified in `fvm_config.json`.
Use `fvm flutter` in place of the global `flutter` command when building or
running the game.

The project is released under the [MIT License](LICENSE).
