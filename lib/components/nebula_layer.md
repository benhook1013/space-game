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
- Nebula tiles reuse the starfield's caching system and background isolate to
  avoid frame spikes. Sprites may be 512×512 noise textures tinted at load time.
- Galaxy bitmap loads through `Assets` and draws with a fixed offset for a slow
  parallax effect. Multiple bitmaps could randomise orientation.
- Component priority sits between the starfield and gameplay components so
  overlays appear behind action but above stars.
- All layers must respect debugging controls and hide when the game's debug mode
  is disabled.

## Open Questions

- Which noise algorithm and parameters produce appealing nebula patterns?
- How should colour palettes be chosen or themed?
- Should the galaxy overlay support animation or multiple variants?
