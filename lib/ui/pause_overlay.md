# PauseOverlay

Overlay displayed when the game is paused.

## Features

- Shows a "Paused" label with resume, restart, menu and mute buttons.
- Triggered from the HUD pause button or the Escape or `P` key.
- Visible only while the game state is `paused`.
- Press `R` to restart without using the button.
- Pressing `M` also toggles audio mute.
- Press `Q` to return to the menu without clicking the button.
- Help button (or `H` key) opens a control reference and resumes when closed;
  `Esc` also closes it.

See [../../PLAN.md](../../PLAN.md) for UI goals.
