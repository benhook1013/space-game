# 🏁 Milestone: Setup

Initial scaffolding so the game builds in the browser.
See [PLAN.md](PLAN.md) for the broader roadmap and
[TASKS.md](TASKS.md) for the consolidated backlog.

## Tasks

- [ ] Pin the Flutter SDK with FVM (`fvm install` and `fvm use`) targeting version
      `3.32.8` as specified in `fvm_config.json`.
- [ ] Run `fvm flutter doctor` to verify the environment.
- [ ] Scaffold the project if needed: `fvm flutter create .`.
- [ ] Enable web support: `fvm flutter config --enable-web`.
- [ ] Add `flame`, `flame_audio` and `shared_preferences` to `pubspec.yaml`.
- [ ] Run `fvm flutter pub get` to install dependencies.
- [ ] Create placeholder `assets.dart` and `constants.dart` to centralise asset
      paths and tunable values.
- [ ] Add a tiny `log.dart` helper that wraps `debugPrint`.
- [ ] Commit generated folders (`lib/`, `web/`, etc.) and `pubspec.lock`.
- [x] Create `assets_manifest.json` to list bundled assets for caching
      (see `assets_manifest.md`).
- [ ] Set up a minimal GitHub Actions workflow for lint, test and web deploy.
- [ ] Document placeholder assets and credits.

## Notes

- Use `fvm flutter` and `fvm dart` for all commands.
- Run `fvm dart format .` and `fvm dart analyze` before committing.
- After editing docs, run `npx markdownlint '**/*.md'`.
