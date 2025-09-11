import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/upgrades_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggleUpgrades pauses and resumes the game', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.overlays
      ..addEntry(UpgradesOverlay.id, (_, __) => const SizedBox())
      ..addEntry(HudOverlay.id, (_, __) => const SizedBox());

    game.stateMachine.state = GameState.playing;
    game.overlayService.showHud();
    game.resumeEngine();
    expect(game.overlays.isActive(UpgradesOverlay.id), isFalse);
    expect(game.paused, isFalse);

    game.ui.toggleUpgrades();
    expect(game.overlays.isActive(UpgradesOverlay.id), isTrue);
    expect(game.paused, isTrue);

    game.ui.toggleUpgrades();
    expect(game.overlays.isActive(UpgradesOverlay.id), isFalse);
    expect(game.paused, isFalse);
  });
}
