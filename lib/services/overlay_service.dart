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

  void showMenu() {
    game.overlays
      ..remove(HudOverlay.id)
      ..remove(PauseOverlay.id)
      ..remove(GameOverOverlay.id)
      ..remove(SettingsOverlay.id)
      ..add(MenuOverlay.id);
  }

  void showHud() {
    game.overlays
      ..remove(MenuOverlay.id)
      ..remove(PauseOverlay.id)
      ..remove(GameOverOverlay.id)
      ..remove(SettingsOverlay.id)
      ..add(HudOverlay.id);
  }

  void showPause() {
    game.overlays
      ..remove(SettingsOverlay.id)
      ..add(PauseOverlay.id);
  }

  void showGameOver() {
    game.overlays
      ..remove(HudOverlay.id)
      ..remove(PauseOverlay.id)
      ..remove(SettingsOverlay.id)
      ..add(GameOverOverlay.id);
  }

  void showHelp() => game.overlays.add(HelpOverlay.id);

  void hideHelp() => game.overlays.remove(HelpOverlay.id);

  void showUpgrades() {
    game.overlays
      ..remove(HudOverlay.id)
      ..remove(SettingsOverlay.id)
      ..add(UpgradesOverlay.id);
  }

  void hideUpgrades() {
    game.overlays
      ..remove(UpgradesOverlay.id)
      ..remove(SettingsOverlay.id)
      ..add(HudOverlay.id);
  }

  void showSettings() => game.overlays.add(SettingsOverlay.id);

  void hideSettings() => game.overlays.remove(SettingsOverlay.id);
}
