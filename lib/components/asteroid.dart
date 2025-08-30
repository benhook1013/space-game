import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';

/// Neutral obstacle that can be mined for score.
///
/// Instances are pooled by [SpaceGame] to reduce garbage collection. Call
/// [reset] before adding to the game to initialise position and velocity.
class AsteroidComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  AsteroidComponent()
      : super(
          size: Vector2.all(Constants.asteroidSize),
          anchor: Anchor.center,
        );

  final Vector2 _velocity = Vector2.zero();

  /// Prepares the asteroid for reuse.
  void reset(Vector2 position, Vector2 velocity) {
    this.position..setFrom(position);
    _velocity..setFrom(velocity);
    sprite = Sprite(Flame.images.fromCache(Assets.randomAsteroid()));
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;
    if (position.y > game.size.y + size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      removeFromParent();
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    game.releaseAsteroid(this);
  }
}
