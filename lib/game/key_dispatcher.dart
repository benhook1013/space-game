import 'package:flame/components.dart';
import 'package:flutter/services.dart';

/// Maps keyboard keys to callbacks and tracks pressed state.
class KeyDispatcher extends Component with KeyboardHandler {
  final Map<LogicalKeyboardKey, VoidCallback> _down = {};
  final Map<LogicalKeyboardKey, VoidCallback> _up = {};
  final Set<LogicalKeyboardKey> _pressed = <LogicalKeyboardKey>{};
  final Set<LogicalKeyboardKey> _ignored = <LogicalKeyboardKey>{};

  /// Registers callbacks for [key].
  void register(
    LogicalKeyboardKey key, {
    VoidCallback? onDown,
    VoidCallback? onUp,
  }) {
    if (onDown != null) {
      _down[key] = onDown;
    }
    if (onUp != null) {
      _up[key] = onUp;
    }
    _ignored.remove(key);
  }

  /// Unregisters callbacks for [key] and clears pressed state.
  void unregister(LogicalKeyboardKey key) {
    _down.remove(key);
    _up.remove(key);
    _pressed.remove(key);
    _ignored.add(key);
  }

  /// Returns whether [key] is currently pressed.
  bool isPressed(LogicalKeyboardKey key) => _pressed.contains(key);

  /// Returns whether any of [keys] are currently pressed.
  bool isAnyPressed(Iterable<LogicalKeyboardKey> keys) {
    for (final key in keys) {
      if (_pressed.contains(key)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final key = event.logicalKey;
    if (_ignored.contains(key)) {
      _pressed.remove(key);
      return false;
    }
    var handled = false;
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      // Treat repeat events like additional down events but only fire the
      // callback on the first press. Some browsers emit a repeat without an
      // initial down event for keys like the spacebar.
      final firstPress = _pressed.add(key);
      if (firstPress) {
        final callback = _down[key];
        if (callback != null) {
          callback();
          handled = true;
        }
      }
    } else if (event is KeyUpEvent) {
      _pressed.remove(key);
      final callback = _up[key];
      if (callback != null) {
        callback();
        handled = true;
      }
    }
    // Return whether a callback handled the event. Unhandled keys propagate so
    // other components or widgets (like text fields) can respond.
    return handled;
  }
}
