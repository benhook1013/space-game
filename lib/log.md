# log.dart

Tiny logging helper wrapping `debugPrint`.

## Responsibilities

- Provide a simple `log()` function that forwards to `debugPrint` in debug builds.
- Allow silencing logs in release builds.
- Keep the helper dependency-free and lightweight.

See [../PLAN.md](../PLAN.md) for style and testing notes.
