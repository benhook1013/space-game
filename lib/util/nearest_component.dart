import 'package:flame/components.dart';

/// Extension providing nearest-component search utilities.
extension NearestComponent<T extends PositionComponent> on Iterable<T> {
  /// Finds the closest component to [origin].
  ///
  /// Components further than [maxDistance] are ignored. The optional [where]
  /// predicate can be used to filter which components are considered.
  ///
  /// Returns `null` if no component satisfies the criteria.
  T? findClosest(
    Vector2 origin, {
    double maxDistance = double.infinity,
    bool Function(T component)? where,
  }) {
    assert(maxDistance >= 0, 'maxDistance must be non-negative');
    T? closest;
    var closestDistanceSquared = maxDistance * maxDistance;
    for (final component in this) {
      if (where != null && !where(component)) {
        continue;
      }
      final distanceSquared = component.position.distanceToSquared(origin);
      if (distanceSquared < closestDistanceSquared) {
        closest = component;
        closestDistanceSquared = distanceSquared;
      }
    }
    return closest;
  }
}
