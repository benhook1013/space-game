import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/enemy.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

class _TestEnemy extends EnemyComponent {
  @override
  Future<void> onLoad() async {}
}

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick});

  @override
  Future<void> onLoad() async {}
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = _TestPlayer(joystick: joystick);
    add(player);
    onGameResize(
      Vector2.all(Constants.playerSize * Constants.playerScale * 2),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player auto-aims nearest enemy when stationary', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    final enemy = _TestEnemy()..reset(game.player.position + Vector2(100, 0));
    game.add(enemy);
    game.update(0);

    expect(game.player.angle, closeTo(0, 0.001));

    game.update(Constants.playerAutoAimInterval);
    expect(game.player.angle, closeTo(math.pi / 2, 0.001));
  });
}
