# 🎮 Design Overview

This document summarises the current architecture and design goals for Space
Miner. See [PLAN.md](PLAN.md) for the authoritative roadmap. Folder overviews
live in [lib/README.md](lib/README.md), [assets/README.md](assets/README.md),
[web/README.md](web/README.md) and [test/README.md](test/README.md).
Design notes for the central helper files are in
[lib/main.md](lib/main.md), [lib/assets.md](lib/assets.md),
[lib/constants.md](lib/constants.md) and [lib/log.md](lib/log.md).
Modules such as `space_game`, components, overlays and services have dedicated
docs in their respective subfolders.
Milestone goals are detailed in [milestone-setup.md](milestone-setup.md),
[milestone-core-loop.md](milestone-core-loop.md) and
[milestone-polish.md](milestone-polish.md), with the day-to-day backlog in
[TASKS.md](TASKS.md). Future multiplayer ideas live in
[networking.md](networking.md). Detailed module docs live under
[lib/game](lib/game/README.md), [lib/components](lib/components/README.md),
[lib/ui](lib/ui/README.md) and [lib/services](lib/services/README.md).

## Game Concept

Space Miner focuses on hunting asteroids for mineral pickups while timed enemy
groups add bursts of combat. The ship mounts an auto-firing mining laser that
locks onto nearby rocks and a primary cannon that automatically targets the
closest enemy. A blue Tractor Aura around the ship pulls in nearby pickups.
Minerals gathered during play will later fund a wide upgrade
tree spanning weapons and ship systems.

## Design Principles

- Keep the codebase small and understandable for a solo developer.
- Prefer built-in Flutter and Flame features over custom frameworks.
- Minimise dependencies and avoid code generation.
- Collect tunable numbers in `constants.dart` and asset paths in `assets.dart`.
- Use composition and pass dependencies through constructors; keep singletons rare.
- Optimise iteration by running all commands through FVM (`fvm flutter`, `fvm dart`).
- Flutter SDK version pinned to `3.32.8` via
  [`fvm_config.json`](fvm_config.json) for consistent builds.
- Build only the features needed for the current milestone; defer extras until
  they are actually required.
- Favour readability and quick iteration over micro-optimisation.
- Use simple state handling (plain classes or `ValueNotifier`s) instead of heavy
  patterns like BLoC or Redux.
- Provide a small `log()` helper wrapping `debugPrint` so logs can be silenced
  in release builds.

## Workflow & Tooling

- Run all Flutter and Dart commands through [FVM](https://fvm.app/) to use the
  pinned SDK version from `fvm_config.json`.
- Keep commits small and focused on `main`; branch only for larger features.
- Before committing, format and analyse code with `fvm dart format .` and
  `fvm dart analyze`.
- Lint Markdown files with `npx markdownlint-cli '**/*.md'`.
- See [PLAN.md](PLAN.md) for the full development loop.

## Entry Point

- `main.dart` starts the Flutter app using the Flutter SDK pinned via FVM (3.32.8).
- It wraps `SpaceGame` in a `GameWidget`, ensures the PWA manifest loads and
  preloads assets through `Assets.load()` before play.
- Run all development commands through FVM (`fvm flutter`, `fvm dart`) to keep
  the toolchain consistent.

## Game Layers

- `main.dart` boots the app using `GameWidget`, which hosts `SpaceGame` and
  exposes an `overlays` map for menus and the HUD.
- `SpaceGame` extends `FlameGame`, managing world and scene setup while
  scheduling the game loop tick.
- It owns small system classes for input, physics/collisions, entity spawners
  and scoring. Hooks for resource mining, inventory, networking and save/load
  will slot in later milestones.
- Flutter overlays handle menus and the HUD so UI stays outside the game loop.
- A `GameState` enum tracks **menu → playing → paused → game over** transitions.
- `SpaceGame` exposes `ValueNotifier`s for score, minerals, health and high
  score so overlays can react without touching the game loop.
- Asset paths live in a central `assets.dart` registry and tunable numbers live
  in `constants.dart` to avoid magic strings or numbers.

## Components

- Player, enemy, asteroid and bullet components live under `lib/components/`.
- Components mix in `HasGameReference<SpaceGame>` when they need game context.
- Use simple hit boxes (`CircleHitbox`, `RectangleHitbox`) and
  `HasCollisionDetection`.
- An `EnemySpawner` system releases groups of enemies at timed intervals.
- Mining asteroids with the laser awards mineral pickups each time.
- The player mounts two weapons: an auto-firing mining laser that targets
  asteroids in range and a primary cannon that locks onto the nearest enemy.
- Bullets, asteroids and enemies use small object pools to limit garbage
  collection, and unit tests verify pooled instances are reused.
- The player loses health on collision with enemies or asteroids; the game ends
  when health is depleted.
- Shooting enforces a brief cooldown so the player cannot spam bullets.
- Give components deterministic IDs for future multiplayer sync and update
  movement using `dt` to stay frame-rate independent.

## Services

- Small helpers for cross-cutting concerns live under `lib/services/`.
- `audio_service.dart` wraps `flame_audio`, exposing a mute toggle and master
  volume so audio can dim when the game is paused.
- `storage_service.dart` uses `shared_preferences` to persist the local
  high score and settings.
- `score_service.dart` tracks score, minerals and health values.
- `overlay_service.dart` shows and hides the Flutter overlays.
- `settings_service.dart` holds tweakable UI scale values and theme mode.
- `targeting_service.dart` assists auto-aim queries.
- `upgrade_service.dart` manages purchasing upgrades with minerals and exposes
  a `ValueListenable` for bought upgrade ids.
- Add services only when needed to keep the project lightweight.

## State and Data

- Tunable numbers live in `constants.dart`.
- Use immutable data objects and pass dependencies via constructors.
- Local save data will use `shared_preferences` in the MVP.
- State is kept lightweight using plain classes or `ValueNotifier`s.
- Track a mineral currency for mined resources and persist purchased upgrades.

## Upgrades

- Minerals earned from asteroids will fund weapon and ship upgrades in later
  milestones.
- Design upgrades to modify mining efficiency, combat power and utility systems
  without bloating the core game loop.
- `UpgradeService` tracks available upgrades and purchases using minerals.

## Game State Flow

- Play centres on searching for asteroids to mine while surviving periodic enemy
  waves.
- The game starts in a menu overlay that also exposes a mute toggle.
- `SpaceGame` transitions to `playing` when the user taps start.
- Players can pause the game from the HUD or with the Escape or `P` key,
  showing a centered `PAUSED` label with a hint to press `Esc` or `P` to
  resume while gameplay halts.
- During play the HUD provides score, minerals, health, a minimap toggle, pause
  and mute controls.
- On player death, a game over overlay appears with restart, menu and mute buttons.
- A help overlay lists controls and can be toggled with the `H` key, pausing the
  game when opened mid-run. `Esc` also closes it without triggering pause.
- An upgrades overlay (placeholder) opens with the `U` key or HUD button and
  pauses gameplay until dismissed.
- A settings overlay provides sliders for HUD, text and joystick scale along
  with a dark theme toggle.
- A `GameState` enum tracks the current phase.

## Input

- On-screen joystick and fire button mirror keyboard controls (WASD + Space).
- Input handling stays isolated from rendering for easier testing.
- `N` toggles a minimap overlay for navigation.
- `H` toggles a help overlay for quick reference, and `Esc` closes it when
  visible.

## Rendering & Camera

- The world extends beyond the initial viewport and has no fixed bounds. A
  `CameraComponent` tracks the player without clamping while content streams in
  around them.
- Entities that move far outside a cleanup radius despawn via an
  `OffscreenCleanup` mixin. Asteroid and enemy spawners place new objects ahead
  of the player's current heading using this same radius so action stays in
  front of the ship.
- A parallax starfield is tiled procedurally to appear endless.

## Assets

- Art, audio and fonts live under `assets/` with subfolders for images,
  audio and fonts.
- Gameplay code references assets through a central `assets.dart` registry;
  no hard-coded file paths.
- A versioned `assets_manifest.json` tracks files for each release to help with
  caching and PWA updates (see `assets_manifest.md`).
- See [ASSET_GUIDE.md](ASSET_GUIDE.md) for sourcing guidelines and
  [ASSET_CREDITS.md](ASSET_CREDITS.md) for attribution.

## PWA & Platform

- Web-only Flutter app managed through FVM (`fvm flutter` commands).
- `web/manifest.json` and the service worker enable installable offline play.

## Milestones

- See [milestone-setup.md](milestone-setup.md),
  [milestone-core-loop.md](milestone-core-loop.md) and
  [milestone-polish.md](milestone-polish.md) for upcoming work.
