import 'dart:async';

import 'package:flame/components.dart';

import '../constants.dart';

/// Mixin that removes a component once it leaves the world bounds.
///
/// When applied to a [PositionComponent], a child updater is attached that
/// checks the component's position each frame and removes it when offscreen.
mixin OffscreenCleanup on PositionComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_OffscreenCleanupBehavior(this));
  }
}

class _OffscreenCleanupBehavior extends Component {
  _OffscreenCleanupBehavior(this._host);

  final PositionComponent _host;

  @override
  void update(double dt) {
    super.update(dt);
    if (_host.y < -_host.height ||
        _host.y > Constants.worldSize.y + _host.height ||
        _host.x < -_host.width ||
        _host.x > Constants.worldSize.x + _host.width) {
      // Removing a component during the update cycle can trigger concurrent
      // modification errors if collision detection is iterating over the
      // component tree. Scheduling the removal defers it until after the
      // current microtask, avoiding those issues.
      scheduleMicrotask(_host.removeFromParent);
    }
  }
}
