import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/components/asteroid_spawner.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

import 'test_joystick.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: Assets.players.first);

  @override
  Future<void> onLoad() async {}
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    final joystick = TestJoystick();
    await add(joystick);
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
    asteroidSpawner = AsteroidSpawner(random: math.Random(0));
    await add(asteroidSpawner);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.asteroids, ...Assets.players]);
  });

  test('start and stop toggle running state', () async {
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(1000));
    await game.ready();

    game.asteroidSpawner.stop();
    expect(game.asteroidSpawner.isRunning, isFalse);

    game.asteroidSpawner.start();
    expect(game.asteroidSpawner.isRunning, isTrue);

    game.asteroidSpawner.stop();
    expect(game.asteroidSpawner.isRunning, isFalse);
  });

  test('spawns ahead of moving player with correct speed', () async {
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(2000));
    await game.ready();
    game.asteroidSpawner.stop();
    game.children.whereType<AsteroidComponent>().forEach((a) {
      a.removeFromParent();
    });
    game.update(0);

    game.player
      ..angle = 0
      ..isMoving = true
      ..position.setZero();

    game.asteroidSpawner.spawn();
    await game.ready();
    final asteroid = game.children.whereType<AsteroidComponent>().first;
    final delta = asteroid.position - game.player.position;
    expect(delta.y, lessThan(0)); // spawned above player
    expect(
      delta.length,
      closeTo(Constants.despawnRadius * 0.9, Constants.despawnRadius * 0.3),
    );

    final before = asteroid.position.clone();
    game.update(1);
    final moved = asteroid.position - before;
    expect(moved.length, closeTo(Constants.asteroidSpeed, 0.1));
  });
}
