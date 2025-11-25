import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

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
  VoidCallback? onChanged;

  // Overlays that shouldn't be active together. When one of these overlays is
  // shown, all others in the set will be removed to ensure only a single
  // exclusive overlay is visible at a time.
  static const Set<String> _exclusiveIds = {
    MenuOverlay.id,
    HudOverlay.id,
    PauseOverlay.id,
    GameOverOverlay.id,
    SettingsOverlay.id,
    UpgradesOverlay.id,
  };

  void _showExclusive(String id, {Set<String>? remove}) {
    final overlays = game.overlays;
    final ids = remove ?? _exclusiveIds;
    overlays.removeAll(ids.where((other) => other != id));
    overlays.add(id);
    _notifyChanged();
  }

  void showMenu() => _showExclusive(MenuOverlay.id);

  void showHud() => _showExclusive(HudOverlay.id);

  /// Shows the pause overlay without affecting other active overlays.
  void showPause() {
    game.overlays.add(PauseOverlay.id);
    _notifyChanged();
  }

  void showGameOver() => _showExclusive(GameOverOverlay.id);

  void showHelp() {
    game.overlays.add(HelpOverlay.id);
    _notifyChanged();
  }

  void hideHelp() {
    game.overlays.remove(HelpOverlay.id);
    _notifyChanged();
  }

  void showUpgrades() => _showExclusive(UpgradesOverlay.id);

  void hideUpgrades() => showHud();

  void showSettings() {
    game.overlays.add(SettingsOverlay.id);
    _notifyChanged();
  }

  void hideSettings() {
    game.overlays.remove(SettingsOverlay.id);
    _notifyChanged();
  }

  void _notifyChanged() => onChanged?.call();
}
