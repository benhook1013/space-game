import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/game_state_machine.dart';
import 'package:space_game/game/ui_controller.dart';
import 'package:space_game/services/overlay_service.dart';

void main() {
  test('UiController disposes owned notifiers', () {
    final game = FlameGame();
    final overlays = OverlayService(game);
    final stateMachine = GameStateMachine(
      overlays: overlays,
      onStart: () {},
      onPause: () {},
      onResume: () {},
      onGameOver: () {},
      onMenu: () {},
      onEnterUpgrades: () {},
      onExitUpgrades: () {},
    );
    addTearDown(stateMachine.dispose);

    final ui = UiController(
      overlayService: overlays,
      stateMachine: stateMachine,
      player: () => throw UnimplementedError(),
      miningLaser: () => null,
      pauseEngine: () {},
      resumeEngine: () {},
      focusGame: () {},
    );

    ui.showMinimap.value = false;
    ui.dispose();

    expect(() => ui.showMinimap.value = true, throwsFlutterError);
  });
}
