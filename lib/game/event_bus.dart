import 'dart:async';

/// Marker base class for all game events.
///
/// Declared as `sealed` so that all valid game events are defined within this
/// library, enabling the event bus to enforce exhaustiveness when needed.
sealed class GameEvent {}

/// Simple event bus for broadcasting game lifecycle events.
///
/// Uses a single broadcast stream; listeners filter for specific event types
/// using [on].
class GameEventBus {
  GameEventBus()
      : _controller = StreamController<GameEvent>.broadcast(sync: true);

  final StreamController<GameEvent> _controller;

  /// Emits an [event] to all listeners.
  ///
  /// Events emitted after the bus is disposed are silently ignored so callers
  /// don't have to guard against late emits during teardown.
  void emit(GameEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// Returns a stream of events of type [T].
  Stream<T> on<T extends GameEvent>() =>
      _controller.stream.where((event) => event is T).cast<T>();

  /// Closes the underlying stream controller.
  Future<void> dispose() => _controller.close();
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
