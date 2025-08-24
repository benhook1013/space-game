# MenuOverlay

Flutter widget shown before gameplay starts.

## Features

- Displays the game title and current high score.
- Start button signals `SpaceGame` to enter the `playing` state.
- Accesses the game via callbacks or a `ValueNotifier`.
- Visible when `GameState.menu` is active.
- Audio mute toggle available before starting the game.
- Players can also press `M` to toggle mute.
- Press `Enter` to start without clicking the button.
- Help button (or `H` key) lists all controls without starting the game; `Esc`
  closes it.
- Reset button clears the stored high score.

See [../../PLAN.md](../../PLAN.md) for UI goals.
