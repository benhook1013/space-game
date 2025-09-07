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

  void _showOnly(String id, Iterable<String> remove) {
    final overlays = game.overlays;
    for (final overlay in remove) {
      overlays.remove(overlay);
    }
    overlays.add(id);
  }

  void showMenu() => _showOnly(MenuOverlay.id, [
        HudOverlay.id,
        PauseOverlay.id,
        GameOverOverlay.id,
        SettingsOverlay.id,
      ]);

  void showHud() => _showOnly(HudOverlay.id, [
        MenuOverlay.id,
        PauseOverlay.id,
        GameOverOverlay.id,
        SettingsOverlay.id,
      ]);

  /// Shows the pause overlay without affecting other active overlays.
  void showPause() => game.overlays.add(PauseOverlay.id);

  void showGameOver() => _showOnly(GameOverOverlay.id, [
        HudOverlay.id,
        PauseOverlay.id,
        SettingsOverlay.id,
      ]);

  void showHelp() => game.overlays.add(HelpOverlay.id);

  void hideHelp() => game.overlays.remove(HelpOverlay.id);

  void showUpgrades() =>
      _showOnly(UpgradesOverlay.id, [HudOverlay.id, SettingsOverlay.id]);

  void hideUpgrades() =>
      _showOnly(HudOverlay.id, [UpgradesOverlay.id, SettingsOverlay.id]);

  void showSettings() => game.overlays.add(SettingsOverlay.id);

  void hideSettings() => game.overlays.remove(SettingsOverlay.id);
}
