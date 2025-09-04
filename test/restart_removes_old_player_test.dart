import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';
import 'test_images.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restarting removes the previous player instance', () async {
    SharedPreferences.setMockInitialValues({});
    await loadTestImages([...Assets.players, ...Assets.explosions]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(100));

    game.startGame();
    game.player.position.setValues(20, 20);
    // Kill the player.
    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      game.hitPlayer();
    }
    expect(game.stateMachine.state, GameState.gameOver);

    // Restart the game and ensure only one player exists at the spawn point.
    game.startGame();
    final players = game.children.whereType<PlayerComponent>().toList();
    expect(players.length, 1);
    expect(players.first.position, Vector2.zero());
  });
}
