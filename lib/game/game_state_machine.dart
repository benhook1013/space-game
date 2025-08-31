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
  });

  final OverlayService overlays;
  final void Function() onStart;
  final void Function() onPause;
  final void Function() onResume;
  final void Function() onGameOver;
  final void Function() onMenu;

  GameState state = GameState.menu;

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
}
