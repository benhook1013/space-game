# StarfieldComponent

Procedurally renders a simple three-layer starfield behind the game.

- Generates stars on the fly, so no image assets are required.
- Each layer moves at a different speed defined in `constants.dart` to create a
  basic parallax effect.
- Stars vary in brightness for a subtle depth cue.
- Regenerates the star positions whenever the game viewport changes size.
- Added to `SpaceGame` with a negative priority so it always draws beneath
  gameplay components.
