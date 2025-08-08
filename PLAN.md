# 🚀 Space Game Dev Plan

Mobile-first 2D space shooter built with **Flutter** and **Flame**.  The goal is a
playable prototype that installs as a PWA on phones while keeping the codebase
small and easy for one developer to maintain.  Multiplayer or backend features
are long‑term ideas, not immediate priorities.

Keep this plan lean and update it as progress is made.

## 🎯 Goals
- Simple offline shooter using Flutter + Flame.
- PWA install with touch controls.
- Clean code that one person can follow.
- Ship quickly and iterate.

## 🚫 Non‑Goals
- Analytics, accounts, or complex backend.
- Multiplayer and native builds (for later).
- Heavy tooling or asset pipelines.

---

## 🛠️ Setup
1. **Repository**
   - Public GitHub repo `space-game`.
   - Include `README.md`, `.gitignore`, `LICENSE`, `fvm_config.json`.

2. **Toolchain**
   - `fvm install` to download the pinned Flutter SDK.
   - `fvm flutter doctor` and `fvm flutter pub get`.
   - `fvm flutter create .` when ready.
   - Verify with `fvm flutter run -d chrome`.
   - Pin the Flame version in `pubspec.yaml` and run all commands via `fvm`.

3. **Editors & Workflow**
   - Connect Codex or a lightweight editor (VS Code, GitHub Mobile, etc.).
   - Optional: Replit or Termux for quick edits.

---

## 🧾 Design & Docs
- `DESIGN.md` – high‑level game overview.
- `TASKS.md` – prioritized implementation steps.
- Optional milestones (`milestone-1.md`, …).
Keep documents short and update them as features land.

---

## 🏗️ Architecture & Game Flow
- `SpaceGame` extends `FlameGame` in `lib/space_game.dart`.
- `GameWidget` hosts the game and overlays menus/HUD.
- Components live in `lib/components/` (`player.dart`, `enemy.dart`, `asteroid.dart`, `bullet.dart`).
- Game states: main menu → playing → game over.
- Keep classes small with UUIDs and JSON‑serializable state for future multiplayer.
- Model actions (move, shoot, mine) for potential network sync.
- Loop: menu → gameplay → game over with quick restart.

---

## 🎮 MVP Features
- Touch/joystick movement and shooting.
- One enemy type with collision and random spawns.
- Asteroids to mine for score.
- Local high score saved on device.

---

## 🎨 Assets, PWA & Build
- Asset folders:
  - `assets/images/`
  - `assets/sfx/`
  - `assets/music/`
  - `assets/fonts/`
- Placeholder shapes or colors are fine early; document sources in `ASSET_GUIDE.md` and credit in `ASSET_CREDITS.md`.
- Enable web: `fvm flutter config --enable-web`.
- Provide `web/manifest.json` (start_url `/`, display `standalone`, landscape orientation,
  `background_color` `#000000`, `theme_color` `#0f0f0f`) and icons (192x192, 512x512) in `web/icons/`.
- Default `flutter_service_worker.js` handles offline caching.
- Build with `fvm flutter build web` and test with `fvm flutter run -d web-server`.
- Deploy the PWA via GitHub Pages (`gh-pages` branch).
- Use a GitHub Actions workflow to publish `build/web` to `gh-pages`.

---

## ✍️ Code Style
- Use Flutter defaults:
  - `dart format`
  - `flutter analyze`
- Run through `fvm` (`fvm dart format .`, `fvm flutter analyze`).
- Avoid extra linters or hooks.

---

## 🔮 Future Plans
- **Multiplayer** (`networking.md`): host‑authoritative co‑op via WebSocket with
  `WorldState` snapshots and `GameAction` messages.
- **Backend (optional)**: local storage or Firebase sync.
- **Native deployment (optional)**: Codemagic, Play Store, TestFlight when
  needed.
 - Additional features: inventory, upgrades, HUD, menus (main/pause), shop/upgrade UI, sound, save/load.

---

## 🧪 Testing & Docs
- Manual testing only.
- Use `PLAYTEST_CHECKLIST.md`, `MANUAL_TESTING.md`, and optional `playtest_logs/`.
- Update `README.md`, `DESIGN.md`, `networking.md` as the project evolves.

---

## 📌 Project Management
- Keep it simple: work from `main` and create feature branches only when needed.
- Track tasks in `TASKS.md`; skip heavy tools or milestone tracking.

---

## 🔁 Daily Loop
```text
1. Use Codex to write code or docs.
2. Push to GitHub.
3. CI builds the PWA.
4. Test on device and install via "Add to Home Screen".
5. Iterate using TASKS.md.
```

