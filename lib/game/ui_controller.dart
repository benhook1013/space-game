import 'package:flutter/foundation.dart';

import '../components/mining_laser.dart';
import '../components/player.dart';
import '../services/overlay_service.dart';
import '../ui/help_overlay.dart';
import '../ui/settings_overlay.dart';
import 'game_state_machine.dart';

/// Handles overlay toggles and UI state such as the minimap visibility.
class UiController {
  UiController({
    required this.overlayService,
    required this.stateMachine,
    required PlayerComponent Function() player,
    required MiningLaserComponent? Function() miningLaser,
    required this.pauseEngine,
    required this.resumeEngine,
    required this.focusGame,
  })  : _player = player,
        _miningLaser = miningLaser;

  final OverlayService overlayService;
  final GameStateMachine stateMachine;

  /// Suppliers used to fetch the current player and mining laser components.
  ///
  /// The lifecycle manager replaces these components on each new run, so the
  /// UI controller avoids caching stale instances by retrieving them on demand.
  final PlayerComponent Function() _player;
  final MiningLaserComponent? Function() _miningLaser;
  final VoidCallback pauseEngine;
  final VoidCallback resumeEngine;
  final VoidCallback focusGame;

  /// Whether the minimap should be shown in the HUD.
  final ValueNotifier<bool> showMinimap = ValueNotifier<bool>(true);

  bool _helpWasPlaying = false;

  /// Releases resources owned by the controller.
  void dispose() {
    showMinimap.dispose();
  }

  /// Toggles the upgrades overlay and pauses/resumes the game.
  void toggleUpgrades() => stateMachine.toggleUpgrades();

  /// Toggles the help overlay and pauses/resumes if entering from gameplay.
  void toggleHelp() {
    if (overlayService.game.overlays.isActive(HelpOverlay.id)) {
      overlayService.hideHelp();
      if (_helpWasPlaying) {
        resumeEngine();
        focusGame();
      }
    } else {
      _helpWasPlaying = stateMachine.isPlaying;
      overlayService.showHelp();
      if (_helpWasPlaying) {
        pauseEngine();
        _miningLaser()?.stopSound();
      }
    }
  }

  /// Toggles rendering of the player's range rings.
  void toggleRangeRings() {
    _player().toggleRangeRings();
  }

  /// Shows or hides the runtime settings overlay.
  void toggleSettings() {
    if (overlayService.game.overlays.isActive(SettingsOverlay.id)) {
      overlayService.hideSettings();
    } else {
      overlayService.showSettings();
    }
  }

  /// Toggles the minimap visibility in the HUD.
  void toggleMinimap() {
    showMinimap.value = !showMinimap.value;
  }
}
