# test/

Contains automated tests covering core services and game components.

Current suites verify:

- Storage and audio services
- Object pooling for bullets, asteroids and enemies
- OverlayService overlay transitions
- Player shot cooldown logic
- Help overlay pause behaviour

Tests use `flutter_test` and `flame_test` as noted in [../PLAN.md](../PLAN.md).

## Running tests

Execute the suite with the Flutter wrapper script:

```bash
scripts/flutterw test
```

The wrapper automatically enables parallel execution by passing a
`--concurrency` value equal to the number of CPU cores. Set a different
concurrency with the `FLUTTER_TEST_CONCURRENCY` environment variable or by
specifying `--concurrency` explicitly:

```bash
FLUTTER_TEST_CONCURRENCY=8 scripts/flutterw test
scripts/flutterw test --concurrency 4
```
