# GameOverOverlay

Flutter widget shown when the player dies.

## Features

- Displays final score and the persisted high score.
- Tapping restart resets `SpaceGame` to the `playing` state.
- Icon sizes scale with screen size for consistency across devices.
- Press `Enter` or `R` to restart without clicking the button.
- Menu button returns to the title screen.
- Press `Q` or `Esc` to return to the menu without clicking the button.
- Mute button toggles audio via `AudioService`.
- Visible when `GameState.gameOver` is active.
- `M` key toggles audio without using the button.
- Help button (or `H` key) shows a control summary and resumes when closed;
  `Esc` also closes it.

See [../../PLAN.md](../../PLAN.md) for UI goals.
