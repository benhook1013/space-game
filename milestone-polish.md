# ✨ Milestone: Polish

Final touches for the MVP, adding background, audio and persistent score.
See [PLAN.md](PLAN.md) for overall project goals and
[TASKS.md](TASKS.md) for the consolidated backlog.

## Tasks

- [ ] Parallax starfield background renders behind gameplay.
- [ ] Sound effects via `flame_audio` with a mute toggle.
- [ ] Local high score stored on device using `shared_preferences`.
- [ ] Simple HUD and menus layered with Flutter overlays.

## Design Notes

- Use Flame's `ParallaxComponent` for the starfield background.
- Centralise audio assets in `assets.dart` and play them through a small
  audio service.
- Persist the high score with `shared_preferences` using a lightweight storage
  helper.
- Place HUD elements (score, health, mute) in Flutter overlays separate from
  the game loop.
