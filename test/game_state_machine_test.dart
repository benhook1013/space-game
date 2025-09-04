import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/game_state.dart';
import 'package:space_game/game/game_state_machine.dart';
import 'package:space_game/services/overlay_service.dart';

class _FakeOverlayService implements OverlayService {
  @override
  final Game game = FlameGame();

  bool showHudCalled = false;
  bool showPauseCalled = false;
  bool showGameOverCalled = false;
  bool showMenuCalled = false;

  @override
  void showHud() => showHudCalled = true;
  @override
  void showPause() => showPauseCalled = true;
  @override
  void showGameOver() => showGameOverCalled = true;
  @override
  void showMenu() => showMenuCalled = true;

  @override
  void showHelp() {}
  @override
  void hideHelp() {}
  @override
  void showUpgrades() {}
  @override
  void hideUpgrades() {}
  @override
  void showSettings() {}
  @override
  void hideSettings() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameStateMachine', () {
    test('startGame shows HUD and calls onStart', () {
      final overlays = _FakeOverlayService();
      var startCalled = false;
      final stateMachine = GameStateMachine(
        overlays: overlays,
        onStart: () => startCalled = true,
        onPause: () {},
        onResume: () {},
        onGameOver: () {},
        onMenu: () {},
      );

      stateMachine.startGame();

      expect(stateMachine.state, GameState.playing);
      expect(overlays.showHudCalled, isTrue);
      expect(startCalled, isTrue);
    });

    test('pauseGame shows pause overlay and calls onPause', () {
      final overlays = _FakeOverlayService();
      var pauseCalled = false;
      final stateMachine = GameStateMachine(
        overlays: overlays,
        onStart: () {},
        onPause: () => pauseCalled = true,
        onResume: () {},
        onGameOver: () {},
        onMenu: () {},
      )..startGame();

      stateMachine.pauseGame();

      expect(stateMachine.state, GameState.paused);
      expect(overlays.showPauseCalled, isTrue);
      expect(pauseCalled, isTrue);
    });

    test('resumeGame shows HUD and calls onResume', () {
      final overlays = _FakeOverlayService();
      var resumeCalled = false;
      final stateMachine = GameStateMachine(
        overlays: overlays,
        onStart: () {},
        onPause: () {},
        onResume: () => resumeCalled = true,
        onGameOver: () {},
        onMenu: () {},
      )
        ..startGame()
        ..pauseGame();

      overlays.showHudCalled = false;
      stateMachine.resumeGame();

      expect(stateMachine.state, GameState.playing);
      expect(overlays.showHudCalled, isTrue);
      expect(resumeCalled, isTrue);
    });

    test('gameOver shows game over overlay and calls onGameOver', () {
      final overlays = _FakeOverlayService();
      var gameOverCalled = false;
      final stateMachine = GameStateMachine(
        overlays: overlays,
        onStart: () {},
        onPause: () {},
        onResume: () {},
        onGameOver: () => gameOverCalled = true,
        onMenu: () {},
      )..startGame();

      stateMachine.gameOver();

      expect(stateMachine.state, GameState.gameOver);
      expect(overlays.showGameOverCalled, isTrue);
      expect(gameOverCalled, isTrue);
    });

    test('returnToMenu shows menu overlay and calls onMenu', () {
      final overlays = _FakeOverlayService();
      var menuCalled = false;
      final stateMachine = GameStateMachine(
        overlays: overlays,
        onStart: () {},
        onPause: () {},
        onResume: () {},
        onGameOver: () {},
        onMenu: () => menuCalled = true,
      )..startGame();

      stateMachine.returnToMenu();

      expect(stateMachine.state, GameState.menu);
      expect(overlays.showMenuCalled, isTrue);
      expect(menuCalled, isTrue);
    });
  });
}
