import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';

/// Basic foe that drifts toward the player.
class EnemyComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  EnemyComponent({Vector2? position})
    : super(
        position: position,
        size: Vector2.all(Constants.enemySize),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(Assets.enemy);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    final direction = (game.player.position - position).normalized();
    position += direction * Constants.enemySpeed * dt;
    if (position.y > game.size.y + size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      removeFromParent();
    }
  }
}
