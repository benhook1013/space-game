# 🏁 Milestone: Setup

Initial scaffolding so the game builds in the browser.
See [PLAN.md](PLAN.md) for the broader roadmap.

## Goals

- Pin the Flutter SDK with FVM (`fvm install` and `fvm use`) targeting version
  `3.32.8` as specified in `fvm_config.json`.
- Scaffold the project if needed: `fvm flutter create .`.
- Enable web support: `fvm flutter config --enable-web`.
- Add `flame`, `flame_audio` and `shared_preferences` to `pubspec.yaml`.
- Commit generated folders (`lib/`, `web/`, etc.) and `pubspec.lock`.
- Set up a minimal GitHub Actions workflow for lint, test and web deploy.
- Document placeholder assets and credits.

## Notes

- Use `fvm flutter` and `fvm dart` for all commands.
- Run `fvm dart format .` and `fvm dart analyze` before committing.
- After editing docs, run `npx markdownlint '**/*.md'`.
