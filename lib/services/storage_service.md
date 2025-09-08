# StorageService

Handles local persistence using `shared_preferences`.

## Responsibilities

- Save and load the local high score.
- Store settings such as the mute flag.
- Persist the selected player sprite index.
- Provide simple async getters and setters for primitive values.
- Future expansion can add save/load for other data.

## Usage

Create the service with `await StorageService.create()` and call
`getHighScore()`/`setHighScore()` or `isMuted()`/`setMuted()` to read or update
values. Generic helpers `getValue`/`setValue` are also available for storing
`int`, `double`, `bool`, `String` and `List<String>` values under custom keys.
Call `resetHighScore()` to clear the stored high score. The method returns a
`bool` indicating whether the value was successfully removed.

See [../../PLAN.md](../../PLAN.md) for polish goals.
