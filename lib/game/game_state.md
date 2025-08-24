# game_state.dart

Enum describing high-level game phases.

## Values

- `menu` – initial overlay before play.
- `playing` – active gameplay loop.
- `paused` – gameplay halted with a pause overlay to resume or return to menu.
- `gameOver` – player died; show overlay with restart, menu and mute options.

Used by `SpaceGame` to swap overlays and reset state.

See [../../PLAN.md](../../PLAN.md) for the state flow.
