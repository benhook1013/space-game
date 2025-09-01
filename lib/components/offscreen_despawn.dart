import 'package:flame/components.dart';

import '../constants.dart';

/// Mixin that removes a component once it leaves the world bounds.
///
/// Call [removeIfOffscreen] during [update] to automatically clean up
/// entities that drift outside the playable area.
mixin OffscreenDespawn on PositionComponent {
  /// Removes the component if it moves outside the world extents.
  void removeIfOffscreen() {
    if (y < -height ||
        y > Constants.worldSize.y + height ||
        x < -width ||
        x > Constants.worldSize.x + width) {
      removeFromParent();
    }
  }
}
