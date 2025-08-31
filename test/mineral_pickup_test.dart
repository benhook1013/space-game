import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/mineral.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    final keyDispatcher = KeyDispatcher();
    add(keyDispatcher);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    add(player);
    onGameResize(
      Vector2.all(Constants.playerSize * Constants.playerScale * 2),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('destroying asteroid drops mineral pickup', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images
        .loadAll([...Assets.asteroids, Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    final asteroid = game.acquireAsteroid(Vector2.zero(), Vector2.zero());
    await game.add(asteroid);
    game.update(0);
    asteroid.takeDamage(Constants.asteroidMaxHealth);
    game.update(0);
    await game.ready();
    expect(game.mineralPickups.length, 1);
  });

  test('collecting mineral increases total', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    final mineral = game.acquireMineral(game.player.position.clone());
    game.mineralPickups.add(mineral);
    final initial = game.minerals.value;
    game.player.onCollisionStart({}, mineral);

    expect(game.minerals.value, initial + Constants.asteroidMinerals);
  });
}
