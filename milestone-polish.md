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
- [x] Settings overlay with master volume slider and sliders for HUD, minimap,
      text, joystick, targeting, Tractor Aura and mining ranges, plus reset button.
- [x] Engine Tuning upgrade boosts player speed.

## Design Notes

- Background stars are generated per world-space chunk using Poisson-disk
  sampling seeded by chunk coordinates. Low-frequency Simplex noise modulates
  density for clusters and voids. Stars follow a weighted radius/brightness
  distribution with subtle colour jitter and pre-render per chunk to a cached
  `Picture` translated by `-playerPosition`, pruning tiles outside a small
  margin so memory stays bounded and drawing faint-to-bright circles so the
  field stays static as the player moves.
- Centralise audio assets in `assets.dart` and play them through a small
  audio service.
- Persist the high score with `shared_preferences` using a lightweight storage
  helper.
- Place HUD elements (score, health, mute) in Flutter overlays separate from
  the game loop.
