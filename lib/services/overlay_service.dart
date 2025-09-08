import 'package:flame/game.dart';

import '../ui/game_over_overlay.dart';
import '../ui/hud_overlay.dart';
import '../ui/menu_overlay.dart';
import '../ui/pause_overlay.dart';
import '../ui/help_overlay.dart';
import '../ui/upgrades_overlay.dart';
import '../ui/settings_overlay.dart';

/// Handles showing and hiding Flutter overlays.
class OverlayService {
  OverlayService(this.game);

  final Game game;

  void _showOnly(String id, Set<String> remove) {
    final overlays = game.overlays;
    for (final overlay in remove) {
      overlays.remove(overlay);
    }
    overlays.add(id);
  }

  static const _menuRemove = <String>{
    HudOverlay.id,
    PauseOverlay.id,
    GameOverOverlay.id,
    SettingsOverlay.id,
  };

  static const _hudRemove = <String>{
    MenuOverlay.id,
    PauseOverlay.id,
    GameOverOverlay.id,
    SettingsOverlay.id,
  };

  static const _gameOverRemove = <String>{
    HudOverlay.id,
    PauseOverlay.id,
    SettingsOverlay.id,
  };

  void showMenu() => _showOnly(MenuOverlay.id, _menuRemove);

  void showHud() => _showOnly(HudOverlay.id, _hudRemove);

  /// Shows the pause overlay without affecting other active overlays.
  void showPause() => game.overlays.add(PauseOverlay.id);

  void showGameOver() => _showOnly(GameOverOverlay.id, _gameOverRemove);

  void showHelp() => game.overlays.add(HelpOverlay.id);

  void hideHelp() => game.overlays.remove(HelpOverlay.id);

  static const _upgradesRemove = <String>{HudOverlay.id, SettingsOverlay.id};

  static const _hideUpgradesRemove = <String>{
    UpgradesOverlay.id,
    SettingsOverlay.id,
  };

  void showUpgrades() => _showOnly(UpgradesOverlay.id, _upgradesRemove);

  void hideUpgrades() => _showOnly(HudOverlay.id, _hideUpgradesRemove);

  void showSettings() => game.overlays.add(SettingsOverlay.id);

  void hideSettings() => game.overlays.remove(SettingsOverlay.id);
}
