# Space Miner PWA (Flutter + Flame) – Agent Guide

This repository uses a Flutter + Flame stack to build a PWA space shooter. Follow the rules below when contributing.

## 0. Start-of-round handoff

Read [WORKFLOW.md](WORKFLOW.md), [working decisions](docs/development/DECISIONS.md),
[environment notes](docs/development/ENVIRONMENT.md) and the latest
[round log](docs/development/rounds/) before editing. These are the collaboration
source of truth; environment observations are dated, not permanent guarantees.

- Implement bounded rounds as actual files, tests and binary Git patch handoffs.
- Use the latest accepted source, not an unaccepted earlier proposal. Record base
  and result trees; never label reconstructed local commits as upstream history.
- Ben delegates publication of completed rounds to the assistant. Prefer normal
  updates to `main`; when protection requires a PR, open and merge it through
  available tools without handing routine integration back to Ben. Respect
  required checks; never force-push or change protection to bypass a refusal.
- A newer uploaded Linux SDK may be adopted in a scoped compatibility round.
  Inspect its exact version/platform first; align all pins, checksums and needed
  dependency changes rather than running a new SDK behind old wrapper pins.
- Preserve an untouched baseline and roundtrip-test the actual delivered patch.
- Report tests written, tests executed, builds and playtests separately.
- Read known environment failures before retrying setup. Recheck only when
  needed or when an SDK/upload/runtime changes the conditions.
- Keep SDKs, caches, generated handoffs and credentials outside committed source.
- Update decisions, round logs and affected docs so the next agent can resume
  without conversation memory. Do not silently adopt a proposed gameplay redesign.

## 1. General Code Rules

- Provide complete, functional Dart/Flutter code unless code-only is requested.
- Avoid deprecated or unstable Flutter/Flame APIs; pin Flame and other core libs for stability.
- Respect existing architecture; reuse patterns and remove obsolete code if replaced.
- Mark unknown APIs or behaviours as uncertain — don’t guess.
- Hot-reload is fine for UI logic, but restart the full game loop after engine-level changes.
- Never mock or stub data in dev/prod — only in tests or controlled previews.
- Keep solutions simple; check for existing utilities or components before adding new ones.
- Avoid duplication in game systems (input handling, rendering, physics).
- Use the `scripts/flutterw` and `scripts/dartw` wrappers, which bootstrap a
  pinned Flutter SDK into `.tooling/flutter`. If you prefer,
  [FVM](https://fvm.app/) is also configured (`fvm flutter`, `fvm dart`).

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
- Update `PLAYTEST_CHECKLIST.md` whenever new player-facing features land.

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

```text
assets/                 # Art, sound, music
lib/
  main.dart             # App entry
  game/                 # Flame Game subclass & systems
  components/           # Game entities/components
  ui/                   # Flutter widgets for menus/HUD
  services/             # Storage, networking, audio
  theme/                # Game-specific color theme extension
  util/                 # Reusable helpers (object pools, spatial grid)
web/                    # PWA manifest, service worker
.github/workflows/      # CI/CD configs
```

Other docs: `PLAN.md`, `DESIGN.md`, `TASKS.md`, `networking.md`, `ASSET_GUIDE.md`,
`ASSET_CREDITS.md`, `MANUAL_TESTING.md`, `PLAYTEST_CHECKLIST.md`, `playtest_logs/`.

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

- Store versioned asset manifests (`assets_manifest.json`) per release
  (see `assets_manifest.md`).
- Compress textures/audio for web performance.
- Credit and license all third-party assets in `ASSET_CREDITS.md`.
