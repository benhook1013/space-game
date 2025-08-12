# 🎮 Design Overview

This document summarises the current architecture and design goals for Space Miner.
See [PLAN.md](PLAN.md) for the authoritative roadmap.

## Game Layers

- `SpaceGame` extends `FlameGame` and is embedded in a `GameWidget`.
- Flutter overlays handle menus and the HUD so UI stays outside the game loop.
- A `GameState` enum tracks **menu → playing → game over** transitions.
- Systems manage input, collisions, spawning and scoring.
- Assets and tunable constants live in `assets.dart` and `constants.dart` so
  gameplay code avoids raw paths or magic numbers.

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

## Input

- On-screen joystick and fire button mirror keyboard controls (WASD + Space).
- Input handling stays isolated from rendering for easier testing.

## Rendering & Camera

- Fixed logical resolution scaled to the device.
- Camera follows the player via `CameraComponent` and `FixedResolutionViewport`.
- A parallax starfield provides the background.

## PWA & Platform

- Web-only Flutter app managed through FVM (`fvm flutter` commands).
- `web/manifest.json` and the service worker enable installable offline play.

## Milestones

- See [milestone-setup.md](milestone-setup.md) and
  [milestone-core-loop.md](milestone-core-loop.md) for upcoming work.
