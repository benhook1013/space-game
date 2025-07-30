# Space Miner PWA

This repository hosts a Codex-driven 2D space shooter prototype. The goal is to build a mobile-friendly game in Flutter with Flame, complete with Progressive Web App (PWA) support and future host-based multiplayer.

See [PLAN.md](PLAN.md) for the full development outline.
Core assets live under the `assets/` directory. Guidelines are in [ASSET_GUIDE.md](ASSET_GUIDE.md) with credits tracked in [ASSET_CREDITS.md](ASSET_CREDITS.md).
The project is released under the [MIT License](LICENSE).

## Flutter Version Management

This repo uses [FVM](https://fvm.app/) to pin the Flutter SDK version. After cloning, run `fvm install` to download the SDK specified in `fvm_config.json`. Use `fvm flutter` in place of the global `flutter` command when building or running the game.
