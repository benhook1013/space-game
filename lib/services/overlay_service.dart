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

  // Overlays that shouldn't be active together. When one of the overlays in
  // [_exclusiveMap] is shown, all other overlays in [_exclusiveIds] will be
  // removed. Using a generated map keeps the relationships in sync when new
  // overlays are added.
  static const Set<String> _exclusiveIds = {
    MenuOverlay.id,
    HudOverlay.id,
    PauseOverlay.id,
    GameOverOverlay.id,
    SettingsOverlay.id,
    UpgradesOverlay.id,
  };

  static final Map<String, Set<String>> _exclusiveMap = {
    for (final id in [
      MenuOverlay.id,
      HudOverlay.id,
      GameOverOverlay.id,
      UpgradesOverlay.id,
    ])
      id: _exclusiveIds.difference({id}),
  };

  void _showExclusive(String id, {Set<String>? remove}) =>
      _showOnly(id, remove ?? _exclusiveMap[id] ?? const <String>{});

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
