import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/bullet.dart';
import 'package:space_game/components/explosion.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';

import 'helpers/lifecycle_test_helpers.dart';

Future<SpaceGame> _createStartedGame() async {
  final game = await createLifecycleTestGame(
    includeHudOverlay: true,
    includePauseOverlay: true,
    includeGameOverOverlay: true,
  );

  await game.startGame();
  await game.ready();
  return game;
}

Future<SpaceGame> _createGameOverState() async {
  final game = await _createStartedGame();
  for (var i = 0; i < Constants.playerMaxHealth; i++) {
    game.hitPlayer();
  }
  await game.ready();
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadLifecycleTestImages();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('lifecycle scenarios', () {
    final scenarios = <String, Future<void> Function()>{
      'restarting clears active explosions': () async {
        final game = await _createGameOverState();
        expect(game.children.whereType<ExplosionComponent>(), isNotEmpty);

        await game.startGame();
        await game.ready();
        expect(game.children.whereType<ExplosionComponent>(), isEmpty);
      },
      'restarting immediately clears pending explosions': () async {
        final game = await _createGameOverState();

        unawaited(game.startGame());
        await game.ready();
        expect(game.children.whereType<ExplosionComponent>(), isEmpty);
      },
      'restarting respawns the player at the center': () async {
        final game = await _createGameOverState();
        game.player.position.setValues(20, 20);

        await game.startGame();
        await game.ready();
        final players = game.children.whereType<PlayerComponent>().toList();
        expect(players.length, 1);
        expect(players.first.position, Vector2.zero());
      },
      'onStart resets state and onGameOver stops spawners': () async {
        final game = await createLifecycleTestGame(viewportSize: 200);
        await game.ready();

        game.scoreService.score.value = 10;
        final bullet = game.pools.acquire<BulletComponent>(
          (b) => b.reset(Vector2.zero(), Vector2.zero()),
        );
        await game.add(bullet);
        await game.ready();
        game.pauseEngine();

        game.lifecycle.onStart();
        await game.ready();

        expect(game.paused, isFalse);
        expect(game.scoreService.score.value, 0);
        expect(game.pools.components<BulletComponent>(), isEmpty);
        expect(game.enemySpawner.isRunning, isTrue);

        game.lifecycle.onGameOver();
        expect(game.paused, isTrue);
        expect(game.enemySpawner.isRunning, isFalse);
      },
      'game over activates overlay and stops spawners': () async {
        final game = await _createGameOverState();

        expect(game.stateMachine.state, GameState.gameOver);
        expect(game.overlays.isActive(GameOverOverlay.id), isTrue);
        expect(game.enemySpawner.isRunning, isFalse);
      },
    };

    scenarios.forEach((description, scenario) {
      test(description, () => scenario());
    });
  });

  test('state machine transitions across restarts', () async {
    final game = await createLifecycleTestGame(
      includeHudOverlay: true,
      includePauseOverlay: true,
      includeGameOverOverlay: true,
    );
    await game.ready();

    expect(game.stateMachine.state, GameState.menu);
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);

    await game.startGame();
    expect(game.stateMachine.state, GameState.playing);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);

    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      game.hitPlayer();
    }
    await game.ready();

    expect(game.stateMachine.state, GameState.gameOver);
    expect(game.overlays.isActive(GameOverOverlay.id), isTrue);

    game.returnToMenu();
    await game.ready();
    expect(game.stateMachine.state, GameState.menu);
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);
    expect(game.overlays.isActive(GameOverOverlay.id), isFalse);
    expect(game.overlays.isActive(HudOverlay.id), isFalse);

    await game.startGame();
    expect(game.stateMachine.state, GameState.playing);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
    expect(game.overlays.isActive(MenuOverlay.id), isFalse);
    expect(game.scoreService.score.value, 0);
    expect(game.overlays.isActive(GameOverOverlay.id), isFalse);
  });
}
