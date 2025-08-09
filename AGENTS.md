# Space Miner PWA (Flutter + Flame) – Agent Guide

This repository uses a Flutter + Flame stack to build a PWA space shooter. Follow the rules below when contributing.

## 1. General Code Rules
- Provide complete, functional Dart/Flutter code unless code-only is requested.
- Avoid deprecated or unstable Flutter/Flame APIs; pin Flame and other core libs for stability.
- Respect existing architecture; reuse patterns and remove obsolete code if replaced.
- Mark unknown APIs or behaviours as uncertain — don’t guess.
- Hot-reload is fine for UI logic, but restart the full game loop after engine-level changes.
- Never mock or stub data in dev/prod — only in tests or controlled previews.
- Keep solutions simple; check for existing utilities or components before adding new ones.
- Avoid duplication in game systems (input handling, rendering, physics).
- Use [FVM](https://fvm.app/) for Flutter commands (run `fvm install` once; then `fvm flutter`, `fvm dart`).

## 2. Style and Formatting
- Follow idiomatic Dart formatting using `dart format`.
- Use explicit, descriptive names; avoid magic numbers (store in constants/config).
- Maintain a clean, modular structure — split widgets, game systems, and data models.
- Keep files under ~300 lines; refactor large Flame components into smaller behaviours/systems.
- Target ~100-char line length for readability; don’t break URLs unnecessarily.
- Organise assets and code consistently: `assets/` for art/audio, `lib/` for source.

## 3. Application Logic Design
- Entry point: `main.dart` sets up the FVM-pinned Flutter SDK, loads the PWA manifest, and preloads assets.
- **Game Layering**
  - Game Root (a `FlameGame` subclass) contains:
    - World/scene management
    - Game loop/tick scheduling (host-authoritative mode in future)
    - Input handling
    - Systems/Managers for physics & collisions, entities, resource mining & inventory, networking (future multiplayer), save/load
  - **UI Layer**: Flutter widgets overlaid on the Flame canvas for menus, HUD, dialogs.
    - Separate rendering logic from game state updates.
    - Keep multiplayer hooks abstracted (offline loop runs without net code).
  - Use a centralised asset registry; no direct asset file paths in gameplay logic.

## 4. Data & Entities
- Entities: plain Dart classes or Flame `Component` subclasses.
- IDs: Use UUIDs or deterministic keys for multiplayer sync.
- Use immutable data objects for state snapshots; modify through systems.
- Validation:
  - Prefer non-nullable fields.
  - Throw/assert on invalid game state in dev builds.
- Store PWA saves in local storage / IndexedDB (e.g., `shared_preferences` or `hive`).

## 5. Networking & Multiplayer (Planned)
- Host-authoritative model; one player simulates world, others sync via WebSocket.
- Define JSON action protocol: `{ "type": "move", "payload": {...} }`.
- Keep protocol in a shared module for reuse.
- No NAT traversal; local network / QR connect.
- Abstract the network layer so offline play uses the same code paths.

## 6. Validation & Error Handling
- Always null-check before using optional data.
- Wrap asset loading, networking, and storage ops in try/catch; log errors with context.
- Provide in-game error overlays for critical failures in debug builds.
- For multiplayer, send structured error packets; avoid silent desync.

## 7. Comments & Documentation
- Comment **why** as well as **what**, especially in game loop, physics, and input handling.
- Use `///` doc comments for public classes/methods; use inline `//` for complex logic.
- Explain design trade-offs (e.g., frame-based vs time-based updates).
- Keep `README.md` and `PLAN.md` in sync with architecture changes.

## 8. Performance & Security
- Use Flame’s built-in FPS/timestep handling to avoid frame-dependent logic.
- Minimise allocations in the game loop.
- Use sprite batching where possible.
- Load large assets asynchronously during splash/loading screens.
- Sanitise all network input; never trust remote player data.
- Follow PWA security best practices (HTTPS, manifest, offline cache integrity).

## 9. Refactoring & Review
- Identify anti-patterns (e.g., UI in game systems).
- Don’t change unrelated logic in PRs.
- Remove dead code and outdated comments.
- Favour composition (behaviours, mixins) over deep inheritance in Flame components.

## 10. Project Structure
```
assets/                 # Art, sound, music
lib/
  main.dart             # App entry
  game/                 # Flame Game subclass & systems
  components/           # Game entities/components
  ui/                   # Flutter widgets for menus/HUD
  services/             # Storage, networking, audio
web/                    # PWA manifest, service worker
.github/workflows/      # CI/CD configs
```
Other docs: `PLAN.md`, `ASSET_GUIDE.md`, `ASSET_CREDITS.md`, `MANUAL_TESTING.md`, `PLAYTEST_CHECKLIST.md`, `playtest_logs/`.

## 11. Testing & Observability
- Use `flutter_test` for unit and widget tests; `flame_test` for component/system tests.
- Test core loops: movement, collisions, mining logic.
- Manual testing logs in `playtest_logs/`.
- Enable Flame’s debug mode in dev builds for bounding boxes and FPS.
- Log key game events (e.g., pickups, kills) for debugging multiplayer sync.

## 12. CI/CD
- GitHub Actions:
  - Lint with `dart analyze` and format checks.
  - Run tests on all pushes/PRs.
  - Build web release (`flutter build web`) and deploy to GitHub Pages/Netlify.
  - Cache pub deps for faster builds.
  - Optional: scheduled runs for dependency checks and Lighthouse audits.

## 13. Asset Management
- Store versioned asset manifests (`assets_manifest.json`) per release.
- Compress textures/audio for web performance.
- Credit and license all third-party assets in `ASSET_CREDITS.md`.

