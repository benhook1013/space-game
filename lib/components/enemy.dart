import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/text.dart';

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

  static final TextPaint _debugTextPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xffffffff),
      fontSize: 10,
    ),
  );

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
  void onMount() {
    super.onMount();
    game.enemies.add(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final direction = (game.player.position - position).normalized();
    angle = math.atan2(direction.y, direction.x) + math.pi / 2;
    position += direction * Constants.enemySpeed * dt;
    if (position.y > Constants.worldSize.y + size.y ||
        position.x < -size.x ||
        position.x > Constants.worldSize.x + size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (game.debugMode) {
      final text = '$_health';
      final tp = _debugTextPaint.toTextPainter(text);
      final position = Vector2(
        -tp.width / 2,
        -size.y / 2 - tp.height,
      );
      _debugTextPaint.render(canvas, text, position);
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    game.enemies.remove(this);
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
