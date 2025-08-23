# services/

Optional helpers for cross-cutting concerns.

- `audio_service.dart` will wrap `flame_audio` to play sound effects and
  handle a mute toggle.
- `storage_service.dart` stores the local high score using
  `shared_preferences` and can expand for save/load later.
- Keep services lightweight; add them only when a milestone needs them.

## Planned Services

- [AudioService](audio_service.md) – preloads clips, plays one-shot effects and
  remembers a mute flag.
- [StorageService](storage_service.md) – loads and saves the high score; may
  persist settings or future save data.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
