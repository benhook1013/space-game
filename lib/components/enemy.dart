import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';

/// Basic foe that drifts toward the player.
///
/// Instances are pooled by [SpaceGame] to reduce garbage collection. Call
/// [reset] before adding to the game to initialise position.
class EnemyComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  EnemyComponent()
      : super(
          size: Vector2.all(
            Constants.enemySize * Constants.enemyScale,
          ),
          anchor: Anchor.center,
        );

  /// Prepares the enemy for reuse.
  void reset(Vector2 position) {
    this.position.setFrom(position);
    sprite = Sprite(Flame.images.fromCache(Assets.randomEnemy()));
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    final direction = (game.player.position - position).normalized();
    angle = math.atan2(direction.y, direction.x) + math.pi / 2;
    position += direction * Constants.enemySpeed * dt;
    if (position.y > game.size.y + size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      removeFromParent();
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    game.releaseEnemy(this);
  }
}
