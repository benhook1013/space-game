import 'dart:math' as math;

import 'package:flame/components.dart';

import '../game/space_game.dart';
import '../util/nearest_component.dart';
import 'enemy.dart';
import 'player.dart';

/// Automatically rotates the player toward nearby enemies when idle.
class AutoAimBehavior extends Component
    with HasGameReference<SpaceGame>, ParentIsA<PlayerComponent> {
  @override
  void update(double dt) {
    super.update(dt);
    if (parent.isMoving) {
      return;
    }
    final enemies = game.pools.components<EnemyComponent>();
    final target = enemies.findClosest(
      parent.position,
      maxDistance: game.upgradeService.targetingRange,
    );
    if (target != null) {
      parent.targetAngle = _normalizeAngle(
        math.atan2(
              target.position.y - parent.position.y,
              target.position.x - parent.position.x,
            ) +
            math.pi / 2,
      );
      parent.updateRotation(dt);
    }
  }

  double _normalizeAngle(double a) {
    while (a <= -math.pi) {
      a += math.pi * 2;
    }
    while (a > math.pi) {
      a -= math.pi * 2;
    }
    return a;
  }
}
