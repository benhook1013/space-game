# GalaxyLayer

Optional overlay that displays a distant galaxy bitmap to add depth beyond the starfield.

## Goals

- Draw a subtle parallax galaxy behind gameplay but above the starfield.
- Allow toggling visibility from the settings overlay.
- Support tint and opacity controls.

## Implementation Notes

- Load one or more low-resolution galaxy images through `Assets`.
- Apply a slight parallax offset based on camera movement.
- Component priority sits between the starfield and gameplay components so the overlay stays behind action but above stars.
- Hide the layer when debug mode is disabled so starfield tiles remain clear.
- If multiple images ship, select one at random on start.

## Open Questions

- What resolution keeps download size small without looking blurry?
- Should multiple galaxy bitmaps be blended or animated?
- How should the layer interact with nebula overlays if both are enabled?
