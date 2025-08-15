import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';
import 'enemy.dart';
import 'asteroid.dart';

/// Short-lived projectile fired by the player.
class BulletComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  BulletComponent({required Vector2 position, required Vector2 direction})
      : _direction = direction.normalized(),
        super(
          position: position,
          size: Vector2.all(Constants.bulletSize),
          anchor: Anchor.center,
        );

  final Vector2 _direction;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(Assets.bullet);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _direction * Constants.bulletSpeed * dt;
    if (position.y < -size.y || position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyComponent) {
      other.removeFromParent();
      removeFromParent();
    }
    if (other is AsteroidComponent) {
      other.removeFromParent();
      removeFromParent();
      game.addScore(1);
    }
  }
}
