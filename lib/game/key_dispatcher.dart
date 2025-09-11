import 'package:flame/components.dart';
import 'package:flutter/services.dart';

/// Maps keyboard keys to callbacks and tracks pressed state.
class KeyDispatcher extends Component with KeyboardHandler {
  final Map<LogicalKeyboardKey, _KeyCallbacks> _callbacks = {};
  final Set<LogicalKeyboardKey> _pressed = <LogicalKeyboardKey>{};
  final Set<LogicalKeyboardKey> _ignored = <LogicalKeyboardKey>{};

  /// Registers callbacks for [key].
  void register(
    LogicalKeyboardKey key, {
    VoidCallback? onDown,
    VoidCallback? onUp,
  }) {
    final callbacks = _callbacks.putIfAbsent(key, _KeyCallbacks.new);
    if (onDown != null) {
      callbacks.down.add(onDown);
    }
    if (onUp != null) {
      callbacks.up.add(onUp);
    }
    if (callbacks.isEmpty) {
      _callbacks.remove(key);
    }
    _ignored.remove(key);
  }

  /// Unregisters callbacks for [key] and clears pressed state.
  void unregister(LogicalKeyboardKey key) {
    _callbacks.remove(key);
    _pressed.remove(key);
    _ignored.add(key);
  }

  /// Returns whether [key] is currently pressed.
  bool isPressed(LogicalKeyboardKey key) => _pressed.contains(key);

  /// Returns whether any of [keys] are currently pressed.
  bool isAnyPressed(Iterable<LogicalKeyboardKey> keys) =>
      keys.any(_pressed.contains);

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final key = event.logicalKey;
    if (_ignored.contains(key)) {
      _pressed.remove(key);
      return false;
    }
    final callbacks = _callbacks[key];
    var handled = false;
    if (event is KeyDownEvent) {
      // Always fire the down callback on explicit down events. This avoids
      // missing actions when a prior key up was skipped (e.g. focus loss).
      _pressed.add(key);
      handled = _fire(callbacks?.down) || handled;
    } else if (event is KeyRepeatEvent) {
      // Treat repeat events like down events only if we haven't seen a
      // preceding down. Some browsers emit repeats without an initial down
      // (e.g. spacebar on web).
      final firstPress = _pressed.add(key);
      if (firstPress) {
        handled = _fire(callbacks?.down) || handled;
      }
    } else if (event is KeyUpEvent) {
      _pressed.remove(key);
      handled = _fire(callbacks?.up) || handled;
    }
    // Return whether a callback handled the event. Unhandled keys propagate so
    // other components or widgets (like text fields) can respond.
    return handled;
  }
}

class _KeyCallbacks {
  final List<VoidCallback> down = <VoidCallback>[];
  final List<VoidCallback> up = <VoidCallback>[];

  bool get isEmpty => down.isEmpty && up.isEmpty;
}

bool _fire(List<VoidCallback>? callbacks) {
  if (callbacks == null || callbacks.isEmpty) {
    return false;
  }
  for (final callback in callbacks) {
    callback();
  }
  return true;
}
