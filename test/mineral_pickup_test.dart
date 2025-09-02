import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/mineral.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'test_joystick.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    final keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    joystick = TestJoystick();
    await add(joystick);
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each asteroid damage drops a nearby mineral', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images
        .loadAll([...Assets.asteroids, Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(
      Vector2.all(
        Constants.playerSize *
            (Constants.spriteScale + Constants.playerScale) *
            2,
      ),
    );
    await game.ready();
    game.player.position.setValues(1000, 1000);
    game.update(0);
    game.update(0);

    final asteroid = game.pools.acquire<AsteroidComponent>(
      (a) => a.reset(Vector2.zero(), Vector2.zero()),
    );
    await game.add(asteroid);
    game.update(0);
    final origin = asteroid.position.clone();

    var hits = 0;
    while (asteroid.parent != null && hits < 10) {
      asteroid.takeDamage(1);
      game.update(0);
      game.update(0);
      hits++;
    }
    await game.ready();
    game.update(0);
    game.update(0);
    expect(game.pools.components<MineralComponent>().length, hits);
    for (final mineral in game.pools.components<MineralComponent>()) {
      final offset = mineral.position - origin;
      expect(offset.length, greaterThan(0));
      expect(offset.length, lessThanOrEqualTo(Constants.mineralDropRadius));
    }
  });

  test('collecting mineral increases total', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(
      Vector2.all(
        Constants.playerSize *
            (Constants.spriteScale + Constants.playerScale) *
            2,
      ),
    );
    await game.ready();
    game.update(0);
    game.update(0);

    final mineral = game.pools.acquire<MineralComponent>(
      (m) => m.reset(game.player.position.clone()),
    );
    final initial = game.minerals.value;
    game.player.onCollisionStart({}, mineral);

    expect(game.minerals.value, initial + Constants.asteroidMinerals);
  });
}
