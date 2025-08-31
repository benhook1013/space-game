import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: Assets.players.first);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }
}

class _TestGame extends SpaceGame {
  _TestGame({required super.storageService, required super.audioService});

  @override
  Future<void> onLoad() async {
    keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
    onGameResize(Vector2.all(Constants.playerSize));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('asteroid damage capped by remaining health', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images
        .loadAll([...Assets.asteroids, Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storageService: storage, audioService: audio);
    await game.onLoad();

    final asteroid = game.acquireAsteroid(Vector2.zero(), Vector2.zero());
    await game.add(asteroid);
    game.update(0);
    final initialHealth = asteroid.health;

    asteroid.takeDamage(initialHealth + 5);

    expect(asteroid.health, 0);
    expect(
      game.mineralPickups.length,
      math.min(initialHealth, Constants.asteroidMineralDropMax),
    );
  });
}
