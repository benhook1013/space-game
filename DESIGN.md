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
- Lint Markdown files with `npx markdownlint '**/*.md'`.
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
- Asset paths live in a central `assets.dart` registry and tunable numbers live
  in `constants.dart` to avoid magic strings or numbers.

## Components

- Player, enemy, asteroid and bullet components live under `lib/components/`.
- Components mix in `HasGameRef<SpaceGame>` when they need game context.
- Use simple hit boxes (`CircleHitbox`, `RectangleHitbox`) and
  `HasCollisionDetection`.
- Bullets use a small object pool to limit garbage collection; consider similar
  pools for asteroids.
- Give components deterministic IDs for future multiplayer sync and update
  movement using `dt` to stay frame-rate independent.

## Services

- Small helpers for cross-cutting concerns live under `lib/services/`.
- `audio_service.dart` will wrap `flame_audio` and expose a mute toggle.
- `storage_service.dart` will use `shared_preferences` to persist the local
  high score and can expand for save/load later.
- Add services only when needed to keep the project lightweight.

## State and Data

- Tunable numbers live in `constants.dart`.
- Use immutable data objects and pass dependencies via constructors.
- Local save data will use `shared_preferences` in the MVP.
- State is kept lightweight using plain classes or `ValueNotifier`s.

## Game State Flow

- The game starts in a menu overlay.
- `SpaceGame` transitions to `playing` when the user taps start.
- Players can pause the game from the HUD or with the Escape key,
  showing a pause overlay.
- On player death, a game over overlay appears with a restart button.
- A `GameState` enum tracks the current phase.

## Input

- On-screen joystick and fire button mirror keyboard controls (WASD + Space).
- Input handling stays isolated from rendering for easier testing.

## Rendering & Camera

- Fixed logical resolution scaled to the device.
- Camera follows the player via `CameraComponent` and `FixedResolutionViewport`.
- A parallax starfield provides the background.

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
