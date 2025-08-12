# components/

Gameplay entities and reusable pieces.

- Includes player, enemy, asteroid and bullet components.
- Each extends a Flame component and mixes in `HasGameRef<SpaceGame>`
  when it needs game context.
- Use simple hit boxes like `CircleHitbox` or `RectangleHitbox` with
  `HasCollisionDetection` on the game.
- Pull tunable values from `constants.dart` and asset references from
  `assets.dart`.
- Consider small object pools for frequently spawned objects to reduce
  garbage collection.
