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

  int _health = Constants.enemyMaxHealth;

  /// Prepares the enemy for reuse.
  void reset(Vector2 position) {
    this.position.setFrom(position);
    sprite = Sprite(Flame.images.fromCache(Assets.randomEnemy()));
    _health = Constants.enemyMaxHealth;
  }

  @override
  Future<void> onLoad() async {
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

  @override
  void onRemove() {
    super.onRemove();
    game.releaseEnemy(this);
  }

  /// Reduces health by [amount] and removes the enemy when depleted.
  void takeDamage(int amount) {
    _health -= amount;
    if (_health <= 0 && !isRemoving) {
      game.addScore(Constants.enemyScore);
      removeFromParent();
    }
  }
}
