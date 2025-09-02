import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';
import 'damageable.dart';
import 'offscreen_cleanup.dart';
import 'spawn_remove_emitter.dart';

/// Short-lived projectile fired by the player.
///
/// Instances are pooled by [SpaceGame] to reduce garbage collection. Call
/// [reset] before adding to the game to initialise position and direction.
class BulletComponent extends SpriteComponent
    with
        HasGameReference<SpaceGame>,
        CollisionCallbacks,
        SpawnRemoveEmitter<BulletComponent>,
        OffscreenCleanup {
  BulletComponent()
      : super(size: Vector2.all(Constants.bulletSize), anchor: Anchor.center);

  final Vector2 _direction = Vector2.zero();

  /// Prepares the bullet for reuse.
  void reset(Vector2 position, Vector2 direction) {
    this.position..setFrom(position);
    _direction
      ..setFrom(direction)
      ..normalize();
    angle = math.atan2(_direction.y, _direction.x) + math.pi / 2;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(Assets.bullet);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    position += _direction * Constants.bulletSpeed * dt;
    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other case Damageable damageable) {
      damageable.takeDamage(Constants.bulletDamage);
      removeFromParent();
    }
  }
}
