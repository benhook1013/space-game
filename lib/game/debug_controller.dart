import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Mixin providing debug-mode toggling and propagation to all components.
///
/// When mixed into a [FlameGame], calling [toggleDebug] will update the game's
/// [debugMode] flag and apply the change to all current descendants. Subclasses
/// can override [onDebugModeChanged] to respond to debug mode updates.
///
/// This reduces duplication across game classes that need consistent debug
/// handling.
mixin DebugController on FlameGame {
  /// Toggles the game's debug rendering state.
  void toggleDebug() => _setDebug(!debugMode);

  /// Sets the game's debug flag and propagates to existing components.
  void _setDebug(bool enabled) {
    debugMode = enabled;

    // Propagate the new debug mode to all existing components so built-in
    // debug visuals like hitboxes update immediately.
    for (final child in children) {
      _applyDebugMode(child, enabled);
    }

    onDebugModeChanged(enabled);
  }

  /// Hook for subclasses to respond to debug mode changes.
  void onDebugModeChanged(bool enabled) {}

  void _applyDebugMode(Component component, bool enabled) {
    component.debugMode = enabled;
    for (final child in component.children) {
      _applyDebugMode(child, enabled);
    }
  }
}
