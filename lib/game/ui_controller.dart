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
        _miningLaser = miningLaser {
    overlayService.onChanged = _syncModalOverlays;
  }

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

  /// Tracks modal overlays that should pause the game while visible.
  final Set<String> _activeModalOverlays = <String>{};

  /// Whether the engine was paused due to at least one modal overlay.
  bool _pausedForModalOverlay = false;

  /// Releases resources owned by the controller.
  void dispose() {
    overlayService.onChanged = null;
    showMinimap.dispose();
  }

  /// Toggles the upgrades overlay and pauses/resumes the game.
  void toggleUpgrades() => stateMachine.toggleUpgrades();

  /// Toggles the help overlay and pauses/resumes if entering from gameplay.
  void toggleHelp() {
    _toggleModalOverlay(
      id: HelpOverlay.id,
      show: overlayService.showHelp,
      hide: overlayService.hideHelp,
    );
  }

  /// Toggles rendering of the player's range rings.
  void toggleRangeRings() {
    _player().toggleRangeRings();
  }

  /// Shows or hides the runtime settings overlay.
  void toggleSettings() {
    _toggleModalOverlay(
      id: SettingsOverlay.id,
      show: overlayService.showSettings,
      hide: overlayService.hideSettings,
    );
  }

  /// Toggles the minimap visibility in the HUD.
  void toggleMinimap() {
    showMinimap.value = !showMinimap.value;
  }

  /// Toggles overlays that should pause the game and resume when closed.
  void _toggleModalOverlay({
    required String id,
    required VoidCallback show,
    required VoidCallback hide,
  }) {
    final overlays = overlayService.game.overlays;
    if (overlays.isActive(id)) {
      hide();
      _activeModalOverlays.remove(id);
      if (_pausedForModalOverlay && !_hasActiveModalOverlay()) {
        resumeEngine();
        focusGame();
        _pausedForModalOverlay = false;
      }
    } else {
      final wasPlaying = stateMachine.isPlaying;
      _activeModalOverlays.add(id);
      show();
      if (wasPlaying && !_pausedForModalOverlay) {
        pauseEngine();
        _miningLaser()?.stopSound();
        _pausedForModalOverlay = true;
      }
    }
  }

  bool _hasActiveModalOverlay() {
    final overlays = overlayService.game.overlays;
    return _activeModalOverlays.any(overlays.isActive);
  }

  void _syncModalOverlays() {
    final overlays = overlayService.game.overlays;
    _activeModalOverlays.removeWhere((id) => !overlays.isActive(id));

    if (_pausedForModalOverlay && !_hasActiveModalOverlay()) {
      _pausedForModalOverlay = false;

      if (stateMachine.isPlaying) {
        resumeEngine();
        focusGame();
      }
    }
  }
}
