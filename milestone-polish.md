# ✨ Milestone: Polish

Final touches for the MVP, adding background, audio and persistent score.
See [PLAN.md](PLAN.md) for overall project goals and
[TASKS.md](TASKS.md) for the consolidated backlog.

## Tasks

- [x] Deterministic world-space starfield background renders behind gameplay.
- [x] Implement `audio_service.dart` wrapping `flame_audio` with a
      mute toggle.
- [x] Implement `storage_service.dart` using `shared_preferences`
      to persist the local high score.
- [x] Simple HUD and menus layered with Flutter overlays.
- [x] Menu allows choosing between multiple ship sprites and persists the selection.
- [x] Option to mute or dim audio when the game is paused.
- [x] Settings overlay with sliders for HUD, minimap, text, joystick, targeting,
      Tractor Aura and mining ranges, plus reset button.

## Design Notes

- Background stars are generated per world-space chunk using Poisson-disk
  sampling seeded by chunk coordinates. Low-frequency Simplex noise modulates
  density for clusters and voids. Stars follow a weighted radius/brightness
  distribution with subtle colour jitter and are cached per chunk. A
  `CustomPainter` translates by `-playerPosition` and draws faint-to-bright
  circles, optionally caching layers with `PictureRecorder` if performance dips
  so the field stays static as the player moves.
- Centralise audio assets in `assets.dart` and play them through a small
  audio service.
- Persist the high score with `shared_preferences` using a lightweight storage
  helper.
- Place HUD elements (score, health, mute) in Flutter overlays separate from
  the game loop.
