# PauseOverlay

Overlay displayed when the game is paused.

## Features

- Shows a centered "PAUSED" label with a hint to press `Esc` or `P` to resume.
- Gameplay is halted but the interface, including the HUD, remains visible for
  inspection.
- Triggered from the HUD pause button or the Escape or `P` key.
- Visible only while the game state is `paused`.
- Keyboard shortcuts still work: `R` restarts, `M` toggles audio mute and `H`
  opens the help overlay which resumes when closed; `Q` returns to the menu; and
  `Esc` also closes it.

See [../../PLAN.md](../../PLAN.md) for UI goals.
