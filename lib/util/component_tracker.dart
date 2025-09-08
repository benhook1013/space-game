import 'dart:async';

import 'package:flame/components.dart';

import '../game/event_bus.dart';

/// Tracks the most recently spawned component of type [T].
///
/// Listens for [ComponentSpawnEvent] and [ComponentRemoveEvent] on the
/// provided [GameEventBus] and exposes the current instance via [component].
/// Call [dispose] to cancel internal subscriptions when no longer needed.
class ComponentTracker<T extends Component> {
  ComponentTracker(GameEventBus events) {
    _spawnSub = events.on<ComponentSpawnEvent<T>>().listen((event) {
      _component = event.component;
    });
    _removeSub = events.on<ComponentRemoveEvent<T>>().listen((event) {
      if (identical(_component, event.component)) {
        _component = null;
      }
    });
  }

  late final StreamSubscription<ComponentSpawnEvent<T>> _spawnSub;
  late final StreamSubscription<ComponentRemoveEvent<T>> _removeSub;

  T? _component;

  /// Currently tracked component instance, if any.
  T? get component => _component;

  /// Cancels internal event subscriptions.
  void dispose() {
    _spawnSub.cancel();
    _removeSub.cancel();
  }
}
