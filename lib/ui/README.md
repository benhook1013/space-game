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
- [HudOverlay](hud_overlay.md) – shows score, health and minerals (with icon)
    with minimap toggle, range rings toggle, help, upgrades, mute and pause
    buttons.
- [PauseOverlay](pause_overlay.md) – displays a centered "PAUSED" label with
  instructions to press `Esc` or `P` to resume while the game is paused.
- [GameOverOverlay](game_over_overlay.md) – shows final and high scores with
  restart (button or `Enter`/`R`), menu, help and mute options.
- [HelpOverlay](help_overlay.md) – lists all controls; toggled with `H` and
  pauses gameplay when opened mid-run; `Esc` also closes it.
- [UpgradesOverlay](upgrades_overlay.md) – lists purchasable ship upgrades;
  opened with `U` and pauses gameplay.
- [SettingsOverlay](settings_overlay.md) – adjust HUD, text, joystick scale and
  gameplay ranges, and toggle the dark theme; opened via HUD button.
- The `M` key toggles mute in any overlay; `F1` toggles debug overlays;
  `Enter` starts or restarts from the menu or game over; `R` restarts at any
  time; `Escape` or `P` pauses or resumes; `H` shows or hides the help overlay,
  `U` opens upgrades, `N` toggles the minimap, and `Esc` also closes overlays
  when visible.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
