# ScoreService

Tracks score, minerals, health and high score persistence.

## Responsibilities

- Expose `ValueNotifier`s for score, high score, minerals and health.
- Update totals when the player scores, mines or takes damage.
- Persist and reset the local high score via `StorageService`.

See [../../PLAN.md](../../PLAN.md) for core loop and polish goals.
