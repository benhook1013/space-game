import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pause overlay does not hide HUD', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.overlays
      ..addEntry(HudOverlay.id, (_, __) => const SizedBox())
      ..addEntry(PauseOverlay.id, (_, __) => const SizedBox());

    game.stateMachine.state = GameState.playing;
    game.overlayService.showHud();
    game.resumeEngine();

    game.pauseGame();

    expect(game.stateMachine.state, GameState.paused);
    expect(game.overlays.isActive(PauseOverlay.id), isTrue);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
  });
}
