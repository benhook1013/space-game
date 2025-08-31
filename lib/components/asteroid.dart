import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:meta/meta.dart';
import '../assets.dart';
import '../constants.dart';
import '../game/event_bus.dart';
import '../game/space_game.dart';
import 'debug_health_text.dart';
import '../util/collision_utils.dart';
import 'damageable.dart';
import 'mineral.dart';

/// Neutral obstacle that can be mined for score and minerals.
///
/// Instances are pooled by [SpaceGame] to reduce garbage collection. Call
/// [reset] before adding to the game to initialise position and velocity.
class AsteroidComponent extends SpriteComponent
    with
        HasGameReference<SpaceGame>,
        CollisionCallbacks,
        DebugHealthText,
        SolidBody,
        Damageable {
  AsteroidComponent()
      : super(
          size: Vector2.all(
            Constants.asteroidSize *
                (Constants.spriteScale + Constants.asteroidScale),
          ),
          anchor: Anchor.center,
        );

  final Vector2 _velocity = Vector2.zero();
  static final _rand = math.Random();
  int _health = Constants.asteroidMaxHealth;

  @visibleForTesting
  int get health => _health;

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
    game.eventBus.emit(ComponentSpawnEvent<AsteroidComponent>(this));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final previous = position.clone();
    position += _velocity * dt;
    game.pools.updateAsteroidPosition(this, previous);
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
    renderHealth(canvas, _health);
  }

  @override
  void onRemove() {
    super.onRemove();
    game.eventBus.emit(ComponentRemoveEvent<AsteroidComponent>(this));
  }

  /// Reduces health by [amount], dropping a limited number of minerals and
  /// removing the asteroid when depleted.
  void takeDamage(int amount) {
    final damage = math.min(amount, _health);
    _health -= damage;
    final drops = math.min(damage, Constants.asteroidMineralDropMax);
    for (var i = 0; i < drops; i++) {
      final angle = _rand.nextDouble() * math.pi * 2;
      final distance = _rand.nextDouble() * Constants.mineralDropRadius;
      final offset = Vector2(math.cos(angle), math.sin(angle))..scale(distance);
      final mineral = game.pools.acquireMineral(position + offset);
      game.add(mineral);
      game.eventBus.emit(ComponentSpawnEvent<MineralComponent>(mineral));
      game.addScore(Constants.asteroidScore);
    }
    if (_health <= 0 && !isRemoving) {
      removeFromParent();
    }
  }
}
