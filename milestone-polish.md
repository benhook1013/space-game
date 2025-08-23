# ✨ Milestone: Polish

Final touches for the MVP, adding background, audio and persistent score.
See [PLAN.md](PLAN.md) for overall project goals and
[TASKS.md](TASKS.md) for the consolidated backlog.

## Tasks

- [ ] Parallax starfield background renders behind gameplay.
- [x] Implement `audio_service.dart` wrapping `flame_audio` with a
      mute toggle.
- [x] Implement `storage_service.dart` using `shared_preferences`
      to persist the local high score.
- [ ] Simple HUD and menus layered with Flutter overlays.

## Design Notes

- Use Flame's `ParallaxComponent` for the starfield background.
- Centralise audio assets in `assets.dart` and play them through a small
  audio service.
- Persist the high score with `shared_preferences` using a lightweight storage
  helper.
- Place HUD elements (score, health, mute) in Flutter overlays separate from
  the game loop.
