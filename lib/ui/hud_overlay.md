# HudOverlay

Heads-up display shown during play.

## Features

- Shows current score, high score and health using `ValueNotifier`s from `SpaceGame`.
- Provides auto-aim radius toggle, help, mute and pause buttons bound to
  `SpaceGame` and `AudioService`.
- Icon sizes scale with screen size for better usability on different devices.
- `H` opens the help overlay showing controls; `Esc` closes it.
- `M` key also toggles audio mute.
- `Escape` or `P` keys also pause or resume.
- Press `R` to restart the current run without using on-screen buttons.
- Visible only in the `playing` state.

See [../../PLAN.md](../../PLAN.md) for UI goals.
