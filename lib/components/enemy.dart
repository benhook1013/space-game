import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';
import 'debug_health_text.dart';
import '../util/collision_utils.dart';
import 'damageable.dart';
import 'explosion.dart';
import 'offscreen_cleanup.dart';
import 'spawn_remove_emitter.dart';

/// Basic foe that drifts toward the player.
///
/// Instances are pooled by [SpaceGame] to reduce garbage collection. Call
/// [reset] before adding to the game to initialise position.
class EnemyComponent extends SpriteComponent
    with
        HasGameReference<SpaceGame>,
        CollisionCallbacks,
        DebugHealthText,
        SolidBody,
        Damageable,
        SpawnRemoveEmitter<EnemyComponent>,
        OffscreenCleanup {
  EnemyComponent()
      : super(
          size: Vector2.all(
            Constants.enemySize *
                (Constants.spriteScale + Constants.enemyScale),
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
    final playerPos = game.targetingService.playerPosition;
    if (playerPos != null) {
      final direction = (playerPos - position).normalized();
      angle = math.atan2(direction.y, direction.x) + math.pi / 2;
      position += direction * Constants.enemySpeed * dt;
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderHealth(canvas, _health);
  }

  /// Reduces health by [amount] and removes the enemy when depleted.
  void takeDamage(int amount) {
    _health -= amount;
    if (_health <= 0 && !isRemoving) {
      game
        ..addScore(Constants.enemyScore)
        ..audioService.playExplosion()
        ..add(ExplosionComponent(position: position.clone()));
      removeFromParent();
    }
  }
}
