# StorageService

Handles local persistence using `shared_preferences`.

## Responsibilities

- Save and load the local high score.
- Store settings such as the mute flag.
- Provide simple async getters and setters.
- Future expansion can add save/load for other data.

## Usage

Create the service with `await StorageService.create()` and call
`getHighScore()`/`setHighScore()` or `isMuted()`/`setMuted()` to read or update
values.

See [../../PLAN.md](../../PLAN.md) for polish goals.
