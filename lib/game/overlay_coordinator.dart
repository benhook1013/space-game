import '../services/overlay_service.dart';
import '../ui/help_overlay.dart';
import 'lifecycle_manager.dart';
import 'game_state_machine.dart';
import 'shortcut_manager.dart' as game_shortcuts;
import 'ui_controller.dart';
import 'space_game.dart';

/// Coordinates overlay setup and state transitions.
class OverlayCoordinator {
  OverlayCoordinator({required this.game});

  final SpaceGame game;

  late final OverlayService overlayService;
  late final LifecycleManager lifecycle;
  late final GameStateMachine stateMachine;
  late final UiController ui;
  late final game_shortcuts.ShortcutManager shortcuts;

  Future<void> init() async {
    overlayService = OverlayService(game);
    lifecycle = LifecycleManager(game);
    stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: lifecycle.onStart,
      // Keep the engine running when paused so HUD tweaks render live.
      onPause: () {},
      onResume: () {},
      onGameOver: lifecycle.onGameOver,
      onMenu: lifecycle.onMenu,
      onEnterUpgrades: () {
        game.pauseEngine();
        game.miningLaser?.stopSound();
      },
      onExitUpgrades: () {
        game.resumeEngine();
        game.focusGame();
      },
    );

    ui = UiController(
      overlayService: overlayService,
      stateMachine: stateMachine,
      player: () => game.player,
      miningLaser: () => game.miningLaser,
      pauseEngine: game.pauseEngine,
      resumeEngine: game.resumeEngine,
      focusGame: game.focusGame,
    );

    shortcuts = game_shortcuts.ShortcutManager(
      keyDispatcher: game.keyDispatcher,
      stateMachine: stateMachine,
      audioService: game.audioService,
      pauseGame: game.pauseGame,
      resumeGame: game.resumeGame,
      startGame: () => game.startGame(),
      toggleHelp: ui.toggleHelp,
      toggleUpgrades: ui.toggleUpgrades,
      toggleDebug: game.toggleDebug,
      toggleMinimap: ui.toggleMinimap,
      toggleRangeRings: ui.toggleRangeRings,
      toggleSettings: ui.toggleSettings,
      returnToMenu: game.returnToMenu,
      isHelpVisible: () => game.overlays.isActive(HelpOverlay.id),
    );
    stateMachine.returnToMenu();
  }
}
