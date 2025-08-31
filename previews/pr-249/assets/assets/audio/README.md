# audio/

Sound effects and music.

- Keep files small and web-friendly.
- Add `shoot.wav` manually. A simple 0.1 s placeholder beep can be generated
  with FFmpeg, for example:
  `ffmpeg -f lavfi -i "sine=frequency=880:duration=0.1" shoot.wav`.
- List each file in `assets_manifest.json` (see `../../assets_manifest.md`).
- See [../../ASSET_GUIDE.md](../../ASSET_GUIDE.md) for sourcing rules and
  credit assets in [../../ASSET_CREDITS.md](../../ASSET_CREDITS.md).
- See [../../PLAN.md](../../PLAN.md) for asset management guidance.
