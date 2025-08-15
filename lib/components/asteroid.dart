import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';

/// Neutral obstacle that can be mined for score.
class AsteroidComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  AsteroidComponent({required Vector2 position, required Vector2 velocity})
      : _velocity = velocity,
        super(
          position: position,
          size: Vector2.all(Constants.asteroidSize),
          anchor: Anchor.center,
        );

  final Vector2 _velocity;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(Assets.asteroid);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;
    if (position.y > game.size.y + size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      removeFromParent();
    }
  }
}
