import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('full lifecycle from start to menu', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players, ...Assets.explosions]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(200));

    expect(game.stateMachine.state, GameState.menu);
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);

    await game.startGame();
    expect(game.stateMachine.state, GameState.playing);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);

    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      game.hitPlayer();
    }
    expect(game.stateMachine.state, GameState.gameOver);
    expect(game.overlays.isActive(GameOverOverlay.id), isTrue);

    game.returnToMenu();
    expect(game.stateMachine.state, GameState.menu);
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);
    expect(game.overlays.isActive(GameOverOverlay.id), isFalse);
    expect(game.overlays.isActive(HudOverlay.id), isFalse);
  });
}
