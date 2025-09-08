import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../assets.dart';
import '../constants.dart';
import '../enemy_faction.dart';
import '../game/space_game.dart';
import 'debug_health_text.dart';
import '../util/collision_utils.dart';
import 'damageable.dart';
import 'explosion.dart';
import 'offscreen_cleanup.dart';
import 'spawn_remove_emitter.dart';
import 'damage_flash.dart';

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
        OffscreenCleanup,
        DamageFlash {
  EnemyComponent() : super(anchor: Anchor.center);

  late EnemyFaction faction;
  late String spritePath;

  int _health = Constants.enemyMaxHealth;

  /// Prepares the enemy for reuse.
  ///
  /// [spritePath] allows callers to supply a specific sprite so that a group of
  /// enemies can share the same visual even when multiple sprites exist for a
  /// faction. If omitted, a random sprite for [faction] is chosen.
  void reset(
    Vector2 position,
    EnemyFaction faction, {
    String? spritePath,
    bool isBoss = false,
  }) {
    this.position.setFrom(position);
    this.faction = faction;
    this.spritePath = spritePath ??
        (isBoss
            ? Assets.bossForFaction(faction)
            : Assets.randomUnitForFaction(faction));
    sprite = Sprite(Flame.images.fromCache(this.spritePath));
    final baseSize =
        Constants.enemySize * (Constants.spriteScale + Constants.enemyScale);
    size = Vector2.all(baseSize * (isBoss ? Constants.enemyBossScale : 1));
    _health = Constants.enemyMaxHealth;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
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
    flashDamage();
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
