import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/enemy.dart';
import 'package:space_game/components/enemy_spawner.dart';
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
    await super.onLoad();
  }
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    final keyDispatcher = KeyDispatcher();
    add(keyDispatcher);
    final joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
    onGameResize(
      Vector2.all(Constants.playerSize *
          (Constants.spriteScale + Constants.playerScale) *
          2),
    );
    enemySpawner = EnemySpawner(random: math.Random(2));
    add(enemySpawner);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('boss spawns away from minions', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players, ...Assets.enemies]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    await game.ready();
    game.enemySpawner.spawnNow();
    game.update(0);
    await game.ready();
    final enemies = game.children.whereType<EnemyComponent>().toList();
    expect(enemies.length, Constants.enemyGroupSize + 1);
    enemies.sort((a, b) => b.size.x.compareTo(a.size.x));
    final boss = enemies.first;
    final minions = enemies.skip(1).toList();
    for (final m in minions) {
      final distance = m.position.distanceTo(boss.position);
      final minDistance = (m.size.x + boss.size.x) / 2;
      expect(distance >= minDistance, isTrue);
    }
    for (var i = 0; i < minions.length; i++) {
      for (var j = i + 1; j < minions.length; j++) {
        final distance = minions[i].position.distanceTo(minions[j].position);
        final minDistance = (minions[i].size.x + minions[j].size.x) / 2;
        expect(distance >= minDistance, isTrue);
      }
    }
  });
}
