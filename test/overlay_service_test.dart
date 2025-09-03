import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';

import 'package:space_game/services/overlay_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/help_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';
import 'package:space_game/ui/settings_overlay.dart';
import 'package:space_game/ui/upgrades_overlay.dart';

FlameGame _createGame() {
  final game = FlameGame();
  final ids = [
    MenuOverlay.id,
    HudOverlay.id,
    PauseOverlay.id,
    GameOverOverlay.id,
    HelpOverlay.id,
    UpgradesOverlay.id,
    SettingsOverlay.id,
  ];
  for (final id in ids) {
    game.overlays.addEntry(id, (_, __) => const SizedBox());
  }
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OverlayService updates overlay states', () {
    final game = _createGame();
    final service = OverlayService(game);

    service.showMenu();
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);
    expect(game.overlays.isActive(HudOverlay.id), isFalse);

    service.showHud();
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
    expect(game.overlays.isActive(MenuOverlay.id), isFalse);

    service.showPause();
    expect(game.overlays.isActive(PauseOverlay.id), isTrue);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);

    service.showGameOver();
    expect(game.overlays.isActive(GameOverOverlay.id), isTrue);
    expect(game.overlays.isActive(PauseOverlay.id), isFalse);

    service.showHelp();
    expect(game.overlays.isActive(HelpOverlay.id), isTrue);
    service.hideHelp();
    expect(game.overlays.isActive(HelpOverlay.id), isFalse);

    service.showUpgrades();
    expect(game.overlays.isActive(UpgradesOverlay.id), isTrue);
    expect(game.overlays.isActive(HudOverlay.id), isFalse);
    service.hideUpgrades();
    expect(game.overlays.isActive(UpgradesOverlay.id), isFalse);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);

    service.showSettings();
    expect(game.overlays.isActive(SettingsOverlay.id), isTrue);
    service.hideSettings();
    expect(game.overlays.isActive(SettingsOverlay.id), isFalse);
  });
}
