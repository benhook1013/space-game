# HudOverlay

Heads-up display shown during play.

## Features

- Shows current score, health and minerals using centred pill-shaped displays
  driven by `ValueNotifier`s from `SpaceGame`.
- Provides range rings toggle, upgrades, help, mute and pause/resume button
  bound to `SpaceGame` and `AudioService`.
- Toggles a top-left minimap for navigation.
- Icon sizes scale with screen size for better usability on different devices.
- `U` opens the upgrades overlay; `Esc` closes it.
- `H` opens the help overlay showing controls; `Esc` closes it.
- `M` key also toggles audio mute.
- `Escape` or `P` keys also pause or resume.
- Press `R` to restart the current run without using on-screen buttons.
- Press `N` to toggle the minimap without tapping the icon.
- Visible in the `playing` and `paused` states.

See [../../PLAN.md](../../PLAN.md) for UI goals.
