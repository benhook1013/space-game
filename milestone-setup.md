# 🏁 Milestone: Setup

Initial scaffolding so the game builds in the browser.
See [PLAN.md](PLAN.md) for the broader roadmap and
[TASKS.md](TASKS.md) for the consolidated backlog.

## Tasks

- [x] Pin the Flutter SDK with FVM (`fvm install` and `fvm use`) targeting version
      `3.32.8` as specified in `fvm_config.json`.
- [x] Run `fvm flutter doctor` to verify the environment.
- [x] Scaffold the project if needed: `fvm flutter create .`.
- [x] Enable web support: `fvm flutter config --enable-web`.
- [x] Add `flame`, `flame_audio` and `shared_preferences` to `pubspec.yaml`.
- [x] Run `fvm flutter pub get` to install dependencies.
- [x] Create placeholder `assets.dart` and `constants.dart` to centralise asset
      paths and tunable values.
- [x] Add a tiny `log.dart` helper that wraps `debugPrint`.
- [x] Commit generated folders (`lib/`, `web/`, etc.) and `pubspec.lock`.
- [x] Create `assets_manifest.json` to list bundled assets for caching
      (see `assets_manifest.md`).
- [x] Set up a minimal GitHub Actions workflow for lint, test and web deploy.
- [x] Document placeholder assets and credits.

## Notes

- Use `fvm flutter` and `fvm dart` for all commands.
- Run `fvm dart format .` and `fvm dart analyze` before committing.
- After editing docs, run `npx markdownlint '**/*.md'`.
