# 🎮 Design Overview

This document summarises the current architecture and design goals for Space Miner.
See [PLAN.md](PLAN.md) for the authoritative roadmap.

## Game Layers

- `SpaceGame` extends `FlameGame`.
- The Flame canvas hosts the world; Flutter overlays provide menus and HUD.
- Systems manage input, collisions, spawning and game state transitions.
- Assets load through a central `Assets` registry; gameplay code avoids file paths.

## Components

- Player, enemy, asteroid and bullet components live under `lib/components/`.
- Components mix in `HasGameRef<SpaceGame>` when they need game context.
- Use simple hit boxes (`CircleHitbox`, `RectangleHitbox`) and `HasCollisionDetection`.

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
