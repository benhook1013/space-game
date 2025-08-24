# ui/

Flutter overlays and HUD widgets.

- Menus, heads-up display and game-over screens live here.
- Widgets are shown using Flame's `overlays` map so UI stays outside the
  game loop.
- UI reads and updates game state through simple `ValueNotifier`s or
  callbacks exposed by `SpaceGame`.
- Keep rendering separate from gameplay logic to simplify testing.

## Overlays

- [MenuOverlay](menu_overlay.md) – start button and basic instructions.
- [HudOverlay](hud_overlay.md) – shows score and health with mute and pause buttons.
- [PauseOverlay](pause_overlay.md) – displayed when the game is paused with
  resume and menu buttons.
- [GameOverOverlay](game_over_overlay.md) – shows final and high scores with
  restart and menu options.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
