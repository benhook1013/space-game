# StorageService

Handles local persistence using `shared_preferences`.

## Responsibilities

- Save and load the local high score.
- Optionally store settings like the mute flag.
- Provide simple async getters and setters.
- Future expansion can add save/load for other data.

## Usage

Create the service with `await StorageService.create()` and call
`getHighScore()`/`setHighScore()` to read or update the value.

See [../../PLAN.md](../../PLAN.md) for polish goals.
