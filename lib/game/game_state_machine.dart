import 'package:flutter/foundation.dart';

import '../services/overlay_service.dart';
import 'game_state.dart';

/// Handles game lifecycle transitions and coordinates services.
class GameStateMachine {
  GameStateMachine({
    required this.overlays,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onGameOver,
    required this.onMenu,
    required this.onEnterUpgrades,
    required this.onExitUpgrades,
  });

  final OverlayService overlays;
  final void Function() onStart;
  final void Function() onPause;
  final void Function() onResume;
  final void Function() onGameOver;
  final void Function() onMenu;
  final void Function() onEnterUpgrades;
  final void Function() onExitUpgrades;

  final ValueNotifier<GameState> stateNotifier =
      ValueNotifier<GameState>(GameState.menu);
  GameState get state => stateNotifier.value;
  set state(GameState value) => stateNotifier.value = value;

  void startGame() {
    state = GameState.playing;
    overlays.showHud();
    onStart();
  }

  void pauseGame() {
    if (state != GameState.playing) {
      return;
    }
    state = GameState.paused;
    overlays.showPause();
    onPause();
  }

  void resumeGame() {
    if (state != GameState.paused) {
      return;
    }
    state = GameState.playing;
    overlays.showHud();
    onResume();
  }

  void gameOver() {
    state = GameState.gameOver;
    overlays.showGameOver();
    onGameOver();
  }

  void returnToMenu() {
    state = GameState.menu;
    overlays.showMenu();
    onMenu();
  }

  /// Toggles the upgrades overlay and pauses/resumes the game.
  void toggleUpgrades() {
    if (state == GameState.upgrades) {
      state = GameState.playing;
      overlays.hideUpgrades();
      onExitUpgrades();
    } else if (state == GameState.playing) {
      state = GameState.upgrades;
      overlays.showUpgrades();
      onEnterUpgrades();
    }
  }

  /// Releases resources held by the state machine.
  void dispose() {
    stateNotifier.dispose();
  }
}
