import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/text.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';

/// Neutral obstacle that can be mined for score and minerals.
///
/// Instances are pooled by [SpaceGame] to reduce garbage collection. Call
/// [reset] before adding to the game to initialise position and velocity.
class AsteroidComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  AsteroidComponent()
      : super(
          size: Vector2.all(
            Constants.asteroidSize * Constants.asteroidScale,
          ),
          anchor: Anchor.center,
        );

  final Vector2 _velocity = Vector2.zero();
  static final _rand = math.Random();
  int _health = Constants.asteroidMaxHealth;

  static final TextPaint _debugTextPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xffffffff),
      fontSize: 10,
    ),
  );

  /// Prepares the asteroid for reuse.
  void reset(Vector2 position, Vector2 velocity) {
    this.position..setFrom(position);
    _velocity..setFrom(velocity);
    sprite = Sprite(Flame.images.fromCache(Assets.randomAsteroid()));
    _health = Constants.asteroidMinHealth +
        _rand.nextInt(
            Constants.asteroidMaxHealth - Constants.asteroidMinHealth + 1);
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void onMount() {
    super.onMount();
    game.asteroids.add(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;
    if (position.y > Constants.worldSize.y + size.y ||
        position.y < -size.y ||
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
    game.asteroids.remove(this);
    game.releaseAsteroid(this);
  }

  /// Reduces health by [amount] and removes the asteroid when depleted.
  ///
  /// When [awardMinerals] is true (the default) minerals are granted to the
  /// player for each hit, simulating mining laser pulses. Bullet damage passes
  /// `awardMinerals: false` to avoid granting minerals for the main attack.
  void takeDamage(int amount, {bool awardMinerals = true}) {
    _health -= amount;
    game.addScore(Constants.asteroidScore);
    if (awardMinerals) {
      game.addMinerals(Constants.asteroidMinerals);
    }
    if (_health <= 0 && !isRemoving) {
      removeFromParent();
    }
  }
}
