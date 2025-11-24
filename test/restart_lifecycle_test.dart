import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/explosion.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/game_state.dart';

import 'helpers/lifecycle_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadLifecycleTestImages();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('restarting clears active explosions', () async {
    final game = await createLifecycleTestGame(
      includeHudOverlay: true,
      includePauseOverlay: true,
      includeGameOverOverlay: true,
    );

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
    final game = await createLifecycleTestGame(
      includeHudOverlay: true,
      includePauseOverlay: true,
      includeGameOverOverlay: true,
    );

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
    final game = await createLifecycleTestGame(
      includeHudOverlay: true,
      includePauseOverlay: true,
      includeGameOverOverlay: true,
    );

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
