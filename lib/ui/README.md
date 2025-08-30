# ui/

Flutter overlays and HUD widgets.

- Menus, heads-up display and game-over screens live here.
- Widgets are shown using Flame's `overlays` map so UI stays outside the
  game loop.
- UI reads and updates game state through simple `ValueNotifier`s or
  callbacks exposed by `SpaceGame`.
- Keep rendering separate from gameplay logic to simplify testing.

## Overlays

- [MenuOverlay](menu_overlay.md) – start button (or `Enter`), high score with
  reset, help (`H`) and mute toggle.
- [HudOverlay](hud_overlay.md) – shows score, high score, minerals and health with
  auto-aim radius toggle, help, mute and pause buttons.
- [PauseOverlay](pause_overlay.md) – displayed when the game is paused with
  resume, restart, menu, help and mute buttons.
- [GameOverOverlay](game_over_overlay.md) – shows final and high scores with
  restart (button or `Enter`/`R`), menu, help and mute options.
- [HelpOverlay](help_overlay.md) – lists all controls; toggled with `H` and
  pauses gameplay when opened mid-run; `Esc` also closes it.
- The `M` key toggles mute in any overlay; `F1` toggles debug overlays;
  `Enter` starts or restarts from the menu or game over; `R` restarts at any
  time; `Escape` or `P` pauses or resumes; `Q` returns to the menu from pause
  or game over and `Esc` also returns to the menu from game over; `H` shows or
  hides the help overlay, and `Esc` also closes it when visible.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
