import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'pool_manager.dart';
import 'starfield_manager.dart';
import 'debug_controller.dart';

/// Handles debug-mode side effects for [SpaceGame].
///
/// This mixin centralises FpsText management and propagates debug flags
/// to pooled components and the starfield manager.
mixin GameDebugHelper on FlameGame, DebugController {
  /// Manages pooled component debug flags.
  PoolManager get pools;

  /// Controls starfield tile debugging.
  StarfieldManager get starfieldManager;

  FpsTextComponent? _fpsText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (kDebugMode) {
      _fpsText = FpsTextComponent(position: Vector2.all(10));
      await add(_fpsText!);
    }
  }

  @override
  void onDebugModeChanged(bool enabled) {
    super.onDebugModeChanged(enabled);
    pools.applyDebugMode(enabled);
    starfieldManager.updateDebug(enabled);
    if (enabled) {
      if (_fpsText != null && !_fpsText!.isMounted) {
        add(_fpsText!);
      }
    } else {
      _fpsText?.removeFromParent();
    }
  }
}
