# services/

Optional helpers for cross-cutting concerns.

- `audio_service.dart` will wrap `flame_audio` to play sound effects and
  handle a mute toggle.
- `storage_service.dart` will store the local high score using
  `shared_preferences` and can expand for save/load later.
- Keep services lightweight; add them only when a milestone needs them.
