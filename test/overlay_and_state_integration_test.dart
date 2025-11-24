import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/game_state.dart';
import 'package:space_game/game/game_state_machine.dart';
import 'package:space_game/game/ui_controller.dart';
import 'package:space_game/services/overlay_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/help_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';
import 'package:space_game/ui/settings_overlay.dart';
import 'package:space_game/ui/upgrades_overlay.dart';

FlameGame _createGame() {
  final game = FlameGame();
  const ids = [
    MenuOverlay.id,
    HudOverlay.id,
    PauseOverlay.id,
    GameOverOverlay.id,
    HelpOverlay.id,
    UpgradesOverlay.id,
    SettingsOverlay.id,
  ];
  for (final id in ids) {
    game.overlays.addEntry(id, (_, __) => const SizedBox());
  }
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Game overlays and state machine stay in sync across transitions', () {
    final game = _createGame();
    final overlayService = OverlayService(game);

    var startCalled = false;
    var pauseCalled = false;
    var resumeCalled = false;
    var menuCalled = false;
    var gameOverCalled = false;
    var enterUpgradesCalled = false;
    var exitUpgradesCalled = false;
    var enginePaused = false;
    var engineResumed = false;
    var focused = false;

    final stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: () => startCalled = true,
      onPause: () {
        pauseCalled = true;
        enginePaused = true;
      },
      onResume: () {
        resumeCalled = true;
        enginePaused = false;
        engineResumed = true;
      },
      onGameOver: () => gameOverCalled = true,
      onMenu: () => menuCalled = true,
      onEnterUpgrades: () {
        enterUpgradesCalled = true;
        enginePaused = true;
      },
      onExitUpgrades: () {
        exitUpgradesCalled = true;
        enginePaused = false;
        engineResumed = true;
        focused = true;
      },
    );

    final ui = UiController(
      overlayService: overlayService,
      stateMachine: stateMachine,
      player: () => throw UnimplementedError('player not needed'),
      miningLaser: () => null,
      pauseEngine: () => enginePaused = true,
      resumeEngine: () {
        enginePaused = false;
        engineResumed = true;
      },
      focusGame: () => focused = true,
    );

    // Entry to the menu wires up the first overlay.
    stateMachine.returnToMenu();
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);
    expect(stateMachine.isMenu, isTrue);
    expect(menuCalled, isTrue);

    // Starting gameplay shows the HUD and clears out other exclusives.
    stateMachine.startGame();
    expect(stateMachine.isPlaying, isTrue);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
    expect(game.overlays.isActive(MenuOverlay.id), isFalse);
    expect(startCalled, isTrue);

    // Pausing runs the pause callback without hiding HUD elements.
    stateMachine.pauseGame();
    expect(stateMachine.isPaused, isTrue);
    expect(game.overlays.isActive(PauseOverlay.id), isTrue);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
    expect(pauseCalled, isTrue);
    expect(enginePaused, isTrue);

    // Resuming removes the pause overlay and resumes the engine.
    stateMachine.resumeGame();
    expect(stateMachine.isPlaying, isTrue);
    expect(game.overlays.isActive(PauseOverlay.id), isFalse);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
    expect(resumeCalled, isTrue);
    expect(enginePaused, isFalse);
    expect(engineResumed, isTrue);

    // Entering and leaving upgrades pauses and resumes the engine.
    stateMachine.toggleUpgrades();
    expect(stateMachine.isUpgrades, isTrue);
    expect(game.overlays.isActive(UpgradesOverlay.id), isTrue);
    expect(game.overlays.isActive(HudOverlay.id), isFalse);
    expect(enterUpgradesCalled, isTrue);
    expect(enginePaused, isTrue);

    stateMachine.toggleUpgrades();
    expect(stateMachine.isPlaying, isTrue);
    expect(game.overlays.isActive(UpgradesOverlay.id), isFalse);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
    expect(exitUpgradesCalled, isTrue);
    expect(enginePaused, isFalse);
    expect(engineResumed, isTrue);
    expect(focused, isTrue);

    // Game over transitions clean up exclusives and return to menu when requested.
    stateMachine.gameOver();
    expect(stateMachine.isGameOver, isTrue);
    expect(game.overlays.isActive(GameOverOverlay.id), isTrue);
    expect(game.overlays.isActive(HudOverlay.id), isFalse);
    expect(gameOverCalled, isTrue);

    stateMachine.returnToMenu();
    expect(stateMachine.isMenu, isTrue);
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);
    expect(game.overlays.isActive(GameOverOverlay.id), isFalse);

    // Contextual help pauses when entered from gameplay and resumes afterwards.
    stateMachine.state = GameState.playing;
    overlayService.showHud();
    ui.toggleHelp();
    expect(game.overlays.isActive(HelpOverlay.id), isTrue);
    expect(enginePaused, isTrue);

    ui.toggleHelp();
    expect(game.overlays.isActive(HelpOverlay.id), isFalse);
    expect(enginePaused, isFalse);
    expect(engineResumed, isTrue);
    expect(focused, isTrue);

    // Overlay churn should still leave the HUD as the active exclusive overlay.
    for (var i = 0; i < 5; i++) {
      overlayService.showMenu();
      overlayService.showHud();
      overlayService.showPause();
      overlayService.showGameOver();
      overlayService.showHud();
      overlayService.showUpgrades();
      overlayService.hideUpgrades();
      overlayService.showSettings();
      overlayService.hideSettings();
      overlayService.showHelp();
      overlayService.hideHelp();
    }

    expect(game.overlays.isActive(MenuOverlay.id), isFalse);
    expect(game.overlays.isActive(PauseOverlay.id), isFalse);
    expect(game.overlays.isActive(GameOverOverlay.id), isFalse);
    expect(game.overlays.isActive(SettingsOverlay.id), isFalse);
    expect(game.overlays.isActive(UpgradesOverlay.id), isFalse);
    expect(game.overlays.isActive(HelpOverlay.id), isFalse);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
  });
}
