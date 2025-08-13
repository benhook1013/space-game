# ui/

Flutter overlays and HUD widgets.

- Menus, heads-up display and game-over screens live here.
- Widgets are shown using Flame's `overlays` map so UI stays outside the
  game loop.
- UI reads and updates game state through simple `ValueNotifier`s or
  callbacks exposed by `SpaceGame`.
- Keep rendering separate from gameplay logic to simplify testing.

## Planned Overlays

- `MenuOverlay` – start button and basic instructions.
- `HudOverlay` – shows score, health and a mute toggle.
- `GameOverOverlay` – displays final score with a restart option.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
