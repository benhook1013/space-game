import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/help_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';
import 'package:space_game/ui/settings_overlay.dart';
import 'package:space_game/ui/upgrades_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('joystick scale updates fire button and keeps anchors', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays
      ..addEntry(MenuOverlay.id, (_, __) => const SizedBox())
      ..addEntry(HudOverlay.id, (_, __) => const SizedBox())
      ..addEntry(PauseOverlay.id, (_, __) => const SizedBox())
      ..addEntry(GameOverOverlay.id, (_, __) => const SizedBox())
      ..addEntry(SettingsOverlay.id, (_, __) => const SizedBox())
      ..addEntry(HelpOverlay.id, (_, __) => const SizedBox())
      ..addEntry(UpgradesOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2(800, 600));
    await game.ready();

    game.settingsService.joystickScale.value = 1.2;
    await Future<void>.delayed(Duration.zero);

    final bg = game.joystick.background as CircleComponent;
    final fire = game.fireButton.button as CircleComponent;
    expect(bg.radius, 50 * 1.2);
    expect(fire.radius, 30 * 1.2);
    expect(game.joystick.position.x, 40);
    expect(game.joystick.position.y, game.size.y - 40);
    expect(game.fireButton.anchor, Anchor.bottomRight);
  });
}
