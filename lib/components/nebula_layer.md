# NebulaLayer

Optional overlay component that enriches the background with noise-generated
nebulae while keeping the deterministic starfield intact.

## Goals

- Render additional ambience above the starfield but below gameplay.
- Allow enabling or disabling via the settings overlay.
- Generate nebula sprites per tile in a background isolate and cache them.

## Implementation Notes

- Expose brightness and density controls alongside existing starfield settings.
- Nebula tiles reuse the starfield's cache worker to avoid frame spikes. Sprites
  may be 512×512 noise textures tinted at load time.
- Component priority sits between the starfield and gameplay components so the
  layer appears behind action but above stars.
- Debug mode should hide the layer unless explicitly toggled for clarity.

## Open Questions

- Which noise algorithm and parameters produce appealing nebula patterns?
- Should palettes match the starfield's `StarPalette` or provide independent themes?
- How much memory does caching nebula tiles consume, and is an explicit LRU cap needed?
