import 'dart:async';

/// Simple event bus for broadcasting game lifecycle events.
class GameEventBus {
  final StreamController<Object> _controller =
      StreamController<Object>.broadcast(sync: true);

  /// Emits an [event] to all listeners.
  void emit(Object event) => _controller.add(event);

  /// Returns a stream of events of type [T].
  Stream<T> on<T>() => _controller.stream.where((e) => e is T).cast<T>();

  /// Closes the underlying stream controller.
  void dispose() => _controller.close();
}

/// Event fired when a component is spawned.
class ComponentSpawnEvent<T> {
  ComponentSpawnEvent(this.component);
  final T component;
}

/// Event fired when a component is removed.
class ComponentRemoveEvent<T> {
  ComponentRemoveEvent(this.component);
  final T component;
}
