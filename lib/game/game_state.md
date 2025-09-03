# game_state.dart

Enum describing high-level game phases.

## Values

- `menu` – initial overlay before play.
- `playing` – active gameplay loop.
- `upgrades` – upgrade selection overlay while gameplay is paused.
- `paused` – gameplay halted with a `PAUSED` indicator and resume hint;
  keyboard shortcuts still work.
- `gameOver` – player died; show overlay with restart, menu and mute options.

Used by `SpaceGame` to swap overlays and reset state.

See [../../PLAN.md](../../PLAN.md) for the state flow.
