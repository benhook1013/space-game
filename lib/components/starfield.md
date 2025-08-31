# Starfield

Background starfield using Flame's `ParallaxComponent`.

- Generates three random star layers with speeds from `constants.dart` for
  parallax depth.
- Stars are rendered once into images and the parallax system manages scroll
  and wrapping, so no per-frame star updates are needed.
- Added to `SpaceGame` with a negative priority so it always renders beneath
  gameplay components.
