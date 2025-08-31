import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../constants.dart';
import '../game/space_game.dart';
import 'asteroid.dart';
import 'player.dart';
import '../util/nearest_component.dart';

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

    final rangeSquared =
        Constants.playerMiningRange * Constants.playerMiningRange;
    if (_target == null ||
        !_target!.isMounted ||
        _target!.position.distanceToSquared(player.position) > rangeSquared) {
      final asteroids = game.asteroids.isNotEmpty
          ? game.asteroids
          : game.children.whereType<AsteroidComponent>();
      _target = asteroids.findClosest(
        player.position,
        Constants.playerMiningRange,
      );
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
}
