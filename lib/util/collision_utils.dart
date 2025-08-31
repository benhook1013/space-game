import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Mixin that prevents [PositionComponent]s from overlapping by
/// pushing them away from each other when a collision occurs.
mixin SolidBody on PositionComponent, CollisionCallbacks {
  static final _rand = math.Random();

  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollision(intersectionPoints, other);
    if (other is! SolidBody) {
      return;
    }
    final diff = position - other.position;
    var distance = diff.length;
    if (distance == 0) {
      // Components are exactly on top of each other; nudge in a random direction.
      final angle = _rand.nextDouble() * math.pi * 2;
      diff
        ..x = math.cos(angle)
        ..y = math.sin(angle);
      distance = 0.0001;
    }
    final minDistance = (size.x + other.size.x) / 2;
    final overlap = minDistance - distance;
    if (overlap > 0) {
      final push = diff.normalized() * (overlap / 2);
      position.add(push);
      other.position.sub(push);
    }
  }
}
