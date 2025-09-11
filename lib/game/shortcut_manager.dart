import 'package:flutter/services.dart';

import '../services/audio_service.dart';
import 'game_state_machine.dart';
import 'key_dispatcher.dart';

/// Registers global keyboard shortcuts and wires them to actions.
///
/// Supported keys: `Esc`, `P`, `M`, `Enter`, `R`, `H`, `U`, `F1`, `N`, `B`, `O`
/// and `Q`.
class ShortcutManager {
  ShortcutManager({
    required KeyDispatcher keyDispatcher,
    required GameStateMachine stateMachine,
    required AudioService audioService,
    required void Function() pauseGame,
    required void Function() resumeGame,
    required void Function() startGame,
    required void Function() toggleHelp,
    required void Function() toggleUpgrades,
    required void Function() toggleDebug,
    required void Function() toggleMinimap,
    required void Function() toggleRangeRings,
    required void Function() toggleSettings,
    required void Function() returnToMenu,
    required bool Function() isHelpVisible,
  }) {
    keyDispatcher.register(LogicalKeyboardKey.escape, onDown: () {
      if (isHelpVisible()) {
        toggleHelp();
        return;
      }
      if (stateMachine.isPlaying) {
        pauseGame();
      } else if (stateMachine.isPaused) {
        resumeGame();
      }
    });

    keyDispatcher.register(LogicalKeyboardKey.keyP, onDown: () {
      if (stateMachine.isPlaying) {
        pauseGame();
      } else if (stateMachine.isPaused) {
        resumeGame();
      }
    });

    keyDispatcher.register(
      LogicalKeyboardKey.keyM,
      onDown: audioService.toggleMute,
    );

    keyDispatcher.register(LogicalKeyboardKey.enter, onDown: () {
      if (stateMachine.isMenu || stateMachine.isGameOver) {
        startGame();
      }
    });

    keyDispatcher.register(LogicalKeyboardKey.keyR, onDown: () {
      if (stateMachine.isGameOver ||
          stateMachine.isPlaying ||
          stateMachine.isPaused) {
        startGame();
      }
    });

    keyDispatcher.register(
      LogicalKeyboardKey.keyH,
      onDown: toggleHelp,
    );

    keyDispatcher.register(
      LogicalKeyboardKey.keyU,
      onDown: toggleUpgrades,
    );

    keyDispatcher.register(
      LogicalKeyboardKey.f1,
      onDown: toggleDebug,
    );

    keyDispatcher.register(
      LogicalKeyboardKey.keyN,
      onDown: toggleMinimap,
    );

    keyDispatcher.register(
      LogicalKeyboardKey.keyB,
      onDown: toggleRangeRings,
    );

    keyDispatcher.register(
      LogicalKeyboardKey.keyO,
      onDown: toggleSettings,
    );

    keyDispatcher.register(LogicalKeyboardKey.keyQ, onDown: () {
      if (stateMachine.isPaused || stateMachine.isGameOver) {
        returnToMenu();
      }
    });
  }
}
