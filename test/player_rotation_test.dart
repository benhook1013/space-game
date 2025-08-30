import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/player.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

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
    onGameResize(Vector2.all(100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player rotates smoothly toward movement direction', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    // Move down; target angle is pi.
    game.joystick.delta.setValues(0, 1);
    game.player.update(0.05);
    final angleAfterFirstUpdate = game.player.angle;

    // Should have started rotating but not reached the target.
    expect(angleAfterFirstUpdate, greaterThan(0));
    expect(angleAfterFirstUpdate, lessThan(math.pi));

    // Change direction upward before rotation completes.
    game.joystick.delta.setValues(0, -1);
    game.player.update(0.05);
    expect(game.player.angle, lessThan(angleAfterFirstUpdate));

    // Let it finish rotating to the new target.
    game.player.update(1);
    expect(game.player.angle, closeTo(0, 0.001));
  });
}
