import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Mixin that prevents [PositionComponent]s from overlapping by
/// pushing them away from each other when a collision occurs.
///
/// When bodies of different sizes collide, the smaller body is moved
/// entirely to avoid tiny objects pushing larger ones around.
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
      final direction = diff.normalized();
      final selfSize = size.length;
      final otherSize = other.size.length;
      if (selfSize < otherSize) {
        // Current component is smaller; move it out of the way entirely.
        position.add(direction * overlap);
      } else if (selfSize > otherSize) {
        // Other component is smaller; move it out of the way.
        other.position.sub(direction * overlap);
      } else {
        // Components are roughly the same size; split the push.
        final push = direction * (overlap / 2);
        position.add(push);
        other.position.sub(push);
      }
    }
  }
}
