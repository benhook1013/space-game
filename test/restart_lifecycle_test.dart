import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/explosion.dart';
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

  setUpAll(() async {
    await loadTestImages([...Assets.players, ...Assets.explosions]);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<SpaceGame> createGame() async {
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    audio.muted.value = true;
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(100));
    return game;
  }

  test('restarting clears active explosions', () async {
    final game = await createGame();

    await game.startGame();
    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      game.hitPlayer();
    }
    await game.ready();
    expect(game.children.whereType<ExplosionComponent>(), isNotEmpty);

    await game.startGame();
    await game.ready();
    expect(game.children.whereType<ExplosionComponent>(), isEmpty);
  });

  test('restarting immediately clears pending explosions', () async {
    final game = await createGame();

    await game.startGame();
    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      game.hitPlayer();
    }
    // Immediately restart without waiting for lifecycle events to process.
    unawaited(game.startGame());
    await game.ready();
    expect(game.children.whereType<ExplosionComponent>(), isEmpty);
  });

  test('restarting removes the previous player instance', () async {
    final game = await createGame();

    await game.startGame();
    game.player.position.setValues(20, 20);
    // Kill the player.
    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      game.hitPlayer();
    }
    expect(game.stateMachine.state, GameState.gameOver);

    // Restart the game and ensure only one player exists at the spawn point.
    await game.startGame();
    final players = game.children.whereType<PlayerComponent>().toList();
    expect(players.length, 1);
    expect(players.first.position, Vector2.zero());
  });
}
