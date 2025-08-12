# Asset Guide

This project organizes art and audio files under the `assets/` directory.

## Folder layout

- `assets/images/` – sprites, backgrounds and other images
- `assets/audio/` – sound effects and music
- `assets/fonts/` – custom fonts

## Asset tracking

- Keep a versioned `assets_manifest.json` at the project root listing all
  bundled assets. Update it whenever files are added or removed so builds and
  service workers can cache the correct resources.

## Finding assets

Look for public domain or permissively licensed assets from:

- [Kenney](https://kenney.nl/)
- [OpenGameArt](https://opengameart.org/)
- [Itch.io](https://itch.io)
- [Freesound](https://freesound.org)

## Attribution

Always check the license for each asset and provide credit as required.

## Optional tools

- [Aseprite](https://www.aseprite.org/) for pixel art
- [Audacity](https://www.audacityteam.org/) for sound editing
- [Bfxr](https://www.bfxr.net/) for retro sound effects
