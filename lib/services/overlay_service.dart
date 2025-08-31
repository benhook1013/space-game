import 'package:flame/game.dart';

import '../ui/game_over_overlay.dart';
import '../ui/hud_overlay.dart';
import '../ui/menu_overlay.dart';
import '../ui/pause_overlay.dart';
import '../ui/help_overlay.dart';
import '../ui/upgrades_overlay.dart';

/// Handles showing and hiding Flutter overlays.
class OverlayService {
  OverlayService(this.game);

  final Game game;

  void showMenu() {
    game.overlays
      ..remove(HudOverlay.id)
      ..remove(PauseOverlay.id)
      ..remove(GameOverOverlay.id)
      ..add(MenuOverlay.id);
  }

  void showHud() {
    game.overlays
      ..remove(MenuOverlay.id)
      ..remove(PauseOverlay.id)
      ..remove(GameOverOverlay.id)
      ..add(HudOverlay.id);
  }

  void showPause() {
    game.overlays
      ..remove(HudOverlay.id)
      ..add(PauseOverlay.id);
  }

  void showGameOver() {
    game.overlays
      ..remove(HudOverlay.id)
      ..remove(PauseOverlay.id)
      ..add(GameOverOverlay.id);
  }

  void showHelp() => game.overlays.add(HelpOverlay.id);

  void hideHelp() => game.overlays.remove(HelpOverlay.id);

  void showUpgrades() {
    game.overlays
      ..remove(HudOverlay.id)
      ..add(UpgradesOverlay.id);
  }

  void hideUpgrades() {
    game.overlays
      ..remove(UpgradesOverlay.id)
      ..add(HudOverlay.id);
  }
}
