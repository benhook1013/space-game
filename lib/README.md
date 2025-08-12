# lib/ Directory Structure

Source code lives under `lib/`. The folders listed here will be created when
the Flutter project is scaffolded.

This repo uses FVM, so run `fvm flutter` and `fvm dart` for all commands to use
the pinned SDK.

## Top-Level Files

- `main.dart` – entry point launching `SpaceGame` via `GameWidget`.
- `assets.dart` – central registry that preloads images, audio and fonts.
- `constants.dart` – tunable values for speeds, spawn rates and other numbers.

## Folders

- `game/` – `SpaceGame` and global systems such as input handlers,
  collision logic and entity spawners.
- `components/` – gameplay entities like player, enemy, asteroid and bullet
  components. Each mixes in `HasGameRef<SpaceGame>` when game context is
  required.
- `ui/` – Flutter widgets for menus and HUD displayed using Flame overlays.
- `services/` – optional helpers for audio, storage (`shared_preferences`) and
  other utilities added as needed.

See [../PLAN.md](../PLAN.md) for the broader roadmap.
