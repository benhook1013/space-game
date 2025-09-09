import 'package:flame/game.dart';

import '../ui/game_over_overlay.dart';
import '../ui/help_overlay.dart';
import '../ui/hud_overlay.dart';
import '../ui/menu_overlay.dart';
import '../ui/pause_overlay.dart';
import '../ui/settings_overlay.dart';
import '../ui/upgrades_overlay.dart';

/// Handles showing and hiding Flutter overlays.
class OverlayService {
  OverlayService(this.game);

  final Game game;

  void _showOnly(String id, Iterable<String> remove) {
    final overlays = game.overlays;
    overlays
      ..removeAll(remove)
      ..add(id);
  }

  static const _exclusiveOverlays = <String, Set<String>>{
    MenuOverlay.id: {
      HudOverlay.id,
      PauseOverlay.id,
      GameOverOverlay.id,
      SettingsOverlay.id,
      UpgradesOverlay.id,
    },
    HudOverlay.id: {
      MenuOverlay.id,
      PauseOverlay.id,
      GameOverOverlay.id,
      SettingsOverlay.id,
      UpgradesOverlay.id,
    },
    GameOverOverlay.id: {
      HudOverlay.id,
      PauseOverlay.id,
      SettingsOverlay.id,
      UpgradesOverlay.id,
    },
    UpgradesOverlay.id: {
      HudOverlay.id,
      SettingsOverlay.id,
      MenuOverlay.id,
      PauseOverlay.id,
      GameOverOverlay.id,
    },
  };

  void _showExclusive(String id, {Set<String>? remove}) =>
      _showOnly(id, remove ?? _exclusiveOverlays[id] ?? const <String>{});

  void showMenu() => _showExclusive(MenuOverlay.id);

  void showHud() => _showExclusive(HudOverlay.id);

  /// Shows the pause overlay without affecting other active overlays.
  void showPause() => game.overlays.add(PauseOverlay.id);

  void showGameOver() => _showExclusive(GameOverOverlay.id);

  void showHelp() => game.overlays.add(HelpOverlay.id);

  void hideHelp() => game.overlays.remove(HelpOverlay.id);

  void showUpgrades() => _showExclusive(UpgradesOverlay.id);

  void hideUpgrades() => showHud();

  void showSettings() => game.overlays.add(SettingsOverlay.id);

  void hideSettings() => game.overlays.remove(SettingsOverlay.id);
}
