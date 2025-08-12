# 🎮 Design Overview

This document summarises the current architecture and design goals for Space Miner.
See [PLAN.md](PLAN.md) for the authoritative roadmap and
[lib/README.md](lib/README.md) for code layout details. Detailed module docs
live under [lib/game](lib/game/README.md), [lib/components](lib/components/README.md),
[lib/ui](lib/ui/README.md) and [lib/services](lib/services/README.md).

## Design Principles

- Keep the codebase small and understandable for a solo developer.
- Prefer built-in Flutter and Flame features over custom frameworks.
- Minimise dependencies and avoid code generation.
- Collect tunable numbers in `constants.dart` and asset paths in `assets.dart`.
- Use composition and pass dependencies through constructors; keep singletons rare.
- Optimise iteration by running all commands through FVM (`fvm flutter`, `fvm dart`).
- Build only the features needed for the current milestone; defer extras until
  they are actually required.
- Favour readability and quick iteration over micro-optimisation.
- Use simple state handling (plain classes or `ValueNotifier`s) instead of heavy
  patterns like BLoC or Redux.

## Game Layers

- `SpaceGame` extends `FlameGame`, managing world and scene setup while
  scheduling the game loop tick.
- It owns small system classes for input, physics/collisions, entity spawners
  and scoring. Hooks for resource mining, inventory, networking and save/load
  will slot in later milestones.
- Flutter overlays handle menus and the HUD so UI stays outside the game loop.
- A `GameState` enum tracks **menu → playing → game over** transitions.
- Asset paths live in a central `assets.dart` registry and tunable numbers live
  in `constants.dart` to avoid magic strings or numbers.

## Components

- Player, enemy, asteroid and bullet components live under `lib/components/`.
- Components mix in `HasGameRef<SpaceGame>` when they need game context.
- Use simple hit boxes (`CircleHitbox`, `RectangleHitbox`) and
  `HasCollisionDetection`.
- Frequently spawned objects (bullets, asteroids) may use small object pools to
  limit garbage collection.

## State and Data

- Tunable numbers live in `constants.dart`.
- Use immutable data objects and pass dependencies via constructors.
- Local save data will use `shared_preferences` in the MVP.
- State is kept lightweight using plain classes or `ValueNotifier`s.

## Game State Flow

- The game starts in a menu overlay.
- `SpaceGame` transitions to `playing` when the user taps start.
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
  caching and PWA updates.
- See [ASSET_GUIDE.md](ASSET_GUIDE.md) for sourcing guidelines and
  [ASSET_CREDITS.md](ASSET_CREDITS.md) for attribution.

## PWA & Platform

- Web-only Flutter app managed through FVM (`fvm flutter` commands).
- `web/manifest.json` and the service worker enable installable offline play.

## Milestones

- See [milestone-setup.md](milestone-setup.md),
  [milestone-core-loop.md](milestone-core-loop.md) and
  [milestone-polish.md](milestone-polish.md) for upcoming work.
