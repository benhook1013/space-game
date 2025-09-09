import 'dart:async';

/// Marker base class for all game events.
///
/// Declared as `sealed` so that all valid game events are defined within this
/// library, enabling the event bus to enforce exhaustiveness when needed.
sealed class GameEvent {}

/// Simple event bus for broadcasting game lifecycle events.
class GameEventBus {
  final Map<Type, StreamController<GameEvent>> _controllers = {};

  /// Emits an [event] to listeners registered for its type.
  void emit(GameEvent event) {
    _controllers[event.runtimeType]?.add(event);
    _controllers[GameEvent]?.add(event);
  }

  /// Returns a stream of events of type [T].
  Stream<T> on<T extends GameEvent>() {
    final controller = _controllers.putIfAbsent(
      T,
      () => StreamController<GameEvent>.broadcast(sync: true),
    );
    return controller.stream.cast<T>();
  }

  /// Closes all stream controllers.
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

/// Event fired when a component is spawned.
class ComponentSpawnEvent<T> implements GameEvent {
  ComponentSpawnEvent(this.component);
  final T component;
}

/// Event fired when a component is removed.
class ComponentRemoveEvent<T> implements GameEvent {
  ComponentRemoveEvent(this.component);
  final T component;
}
