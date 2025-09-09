# NebulaLayer

Optional overlay component that enriches the background with nebulae or a distant
sample galaxy image while keeping the deterministic starfield intact.

## Goals

- Render additional ambience above the starfield but below gameplay.
- Allow toggling overlays via the settings overlay.
- Support two sources:
  - Noise-generated nebula sprites cached per tile.
  - A large, low-resolution galaxy bitmap with subtle parallax.

## Implementation Notes

- Expose brightness and density controls alongside existing starfield settings.
- Nebula tiles can reuse the starfield's caching system and background isolate
  to avoid frame spikes.
- Galaxy bitmap loads through `Assets` and draws with a fixed offset for a slow
  parallax effect.
- Component priority sits between the starfield and gameplay components so
  overlays appear behind action but above stars.
- All layers must respect debugging controls and hide when the game's debug mode
  is disabled.
