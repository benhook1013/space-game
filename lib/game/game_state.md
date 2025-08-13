# game_state.dart

Enum describing high-level game phases.

## Values

- `menu` – initial overlay before play.
- `playing` – active gameplay loop.
- `gameOver` – player died; show restart overlay.

Used by `SpaceGame` to swap overlays and reset state.

See [../../PLAN.md](../../PLAN.md) for the state flow.
