import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

/// Maps keyboard keys to callbacks and tracks pressed state.
class KeyDispatcher extends Component with KeyboardHandler {
  final Map<LogicalKeyboardKey, VoidCallback> _down = {};
  final Map<LogicalKeyboardKey, VoidCallback> _up = {};
  final Set<LogicalKeyboardKey> _pressed = <LogicalKeyboardKey>{};

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
  }

  /// Returns whether [key] is currently pressed.
  bool isPressed(LogicalKeyboardKey key) => _pressed.contains(key);

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final key = event.logicalKey;
    if (event is KeyDownEvent) {
      _pressed.add(key);
      _down[key]?.call();
    } else if (event is KeyUpEvent) {
      _pressed.remove(key);
      _up[key]?.call();
    }
    return true;
  }
}
