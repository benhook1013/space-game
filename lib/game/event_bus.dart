import 'dart:async';

/// Marker base class for all game events.
abstract class GameEvent {}

/// Simple event bus for broadcasting game lifecycle events.
class GameEventBus {
  final StreamController<GameEvent> _controller =
      StreamController<GameEvent>.broadcast(sync: true);

  /// Emits an [event] to all listeners.
  void emit(GameEvent event) => _controller.add(event);

  /// Returns a stream of events of type [T].
  Stream<T> on<T extends GameEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  /// Closes the underlying stream controller.
  void dispose() => _controller.close();
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
