# NebulaLayer

Overlay component that enriches the background with noise-generated nebulae
while keeping the deterministic starfield intact.

## Goals

- Render additional ambience above the starfield but below gameplay.
- Allow enabling or disabling via the settings overlay.
- Generate nebula sprites per tile in a background isolate and cache them.

## Implementation Notes

- Intensity is controlled via the settings overlay and persisted alongside
  starfield preferences. Setting intensity to zero fades the layer out.
- Nebula tiles are procedural noise textures tinted at render time. They drift
  slowly and crossfade between two tints derived from the current star palette.
- Component priority sits between the starfield and gameplay components so the
  layer appears behind action but above stars.
- Debug mode hides the layer to keep tile outlines legible.

## Open Questions

- Which noise algorithm and parameters produce appealing nebula patterns?
- Should palettes match the starfield's `StarPalette` or provide independent themes?
- How much memory does caching nebula tiles consume, and is an explicit LRU cap needed?
