# services/

Optional helpers for cross-cutting concerns.

- `audio_service.dart` wraps `flame_audio` to play sound effects and
  handles a mute toggle and master volume slider persisted via `StorageService`.
- `storage_service.dart` stores the local high score and mute setting using
  `shared_preferences`.
- `score_service.dart` tracks score, minerals and health values.
- `overlay_service.dart` shows and hides overlays on the `GameWidget`.
- `settings_service.dart` holds UI scale values and gameplay ranges and can
  reset them to defaults.
- `targeting_service.dart` assists auto-aim queries.
- `upgrade_service.dart` manages purchasing upgrades with minerals,
  persists bought upgrades via `StorageService`, and derives gameplay modifiers
  like fire rate and mining speed.
- Keep services lightweight; add them only when a milestone needs them.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
