import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../constants.dart';
import '../game/space_game.dart';
import 'asteroid.dart';
import 'player.dart';

/// Automatically mines the nearest asteroid within range.
class MiningLaserComponent extends Component with HasGameReference<SpaceGame> {
  MiningLaserComponent({required this.player});

  final PlayerComponent player;
  AsteroidComponent? _target;
  final Paint _paint = Paint()..color = const Color(0x66ffffff);
  double _pulseTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!player.isMounted) return;

    if (_target == null ||
        !_target!.isMounted ||
        _target!.position.distanceTo(player.position) >
            Constants.playerMiningRange) {
      _target = _findClosestAsteroid();
      _pulseTimer = 0;
    }

    if (_target != null) {
      _pulseTimer += dt;
      final progress =
          (_pulseTimer / Constants.miningPulseInterval).clamp(0, 1).toDouble();
      _paint.strokeWidth = 2 + 2 * progress;
      if (_pulseTimer >= Constants.miningPulseInterval) {
        _pulseTimer = 0;
        _paint.strokeWidth = 2;
        _target!.takeDamage(Constants.miningPulseDamage);
        if (!_target!.isMounted) {
          _target = null;
        }
      }
    } else {
      _paint.strokeWidth = 2;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_target == null || !_target!.isMounted) return;
    canvas.drawLine(
      player.position.toOffset(),
      _target!.position.toOffset(),
      _paint,
    );
  }

  AsteroidComponent? _findClosestAsteroid() {
    AsteroidComponent? closest;
    var closestDistance = Constants.playerMiningRange;
    Iterable<AsteroidComponent> asteroids = game.asteroids;
    if (asteroids.isEmpty) {
      asteroids = game.children.whereType<AsteroidComponent>();
    }
    for (final asteroid in asteroids) {
      final distance = asteroid.position.distanceTo(player.position);
      if (distance <= closestDistance) {
        closest = asteroid;
        closestDistance = distance;
      }
    }
    return closest;
  }
}
