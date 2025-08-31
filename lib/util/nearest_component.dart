import 'package:flame/components.dart';

/// Extension providing nearest-component search utilities.
extension NearestComponent<T extends PositionComponent> on Iterable<T> {
  /// Finds the closest component to [origin] within [maxDistance].
  ///
  /// Returns `null` if no component is within the distance threshold.
  T? findClosest(Vector2 origin, double maxDistance) {
    T? closest;
    var closestDistanceSquared = maxDistance * maxDistance;
    for (final component in this) {
      final distanceSquared = component.position.distanceToSquared(origin);
      if (distanceSquared < closestDistanceSquared) {
        closest = component;
        closestDistanceSquared = distanceSquared;
      }
    }
    return closest;
  }
}
