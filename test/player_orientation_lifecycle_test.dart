import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';
import 'test_joystick.dart';

class _FakeAudioService implements AudioService {
  @override
  final ValueNotifier<bool> muted = ValueNotifier(false);
  @override
  final ValueNotifier<double> volume = ValueNotifier<double>(1);

  @override
  double get masterVolume => volume.value;
  @override
  AudioPlayer? get miningLoop => null;
  @override
  Future<void> startMiningLaser() async {}
  @override
  void stopAll() {}
  @override
  void stopMiningLaser() {}
  @override
  void playShoot() {}
  @override
  void playExplosion() {}
  @override
  Future<void> toggleMute() async {}
  @override
  void setMasterVolume(double volume) {
    this.volume.value = volume.clamp(0, 1).toDouble();
  }

  @override
  void dispose() {}
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  late TestJoystick testJoystick;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    controlManager.joystick.removeFromParent();
    testJoystick = TestJoystick();
    await add(testJoystick);
    player
      ..setJoystick(testJoystick)
      ..resetInput();
    player.inputBehavior.game = this;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player rotation smoothing and resets in a single lifecycle', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players]);
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
    final game = _TestGame(storage: storage, audio: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(
      Vector2.all(
        Constants.playerSize *
            (Constants.spriteScale + Constants.playerScale) *
            2,
      ),
    );
    await game.ready();
    game.resumeEngine();
    game.update(0);
    game.update(0);

    final input = game.player.inputBehavior;

    // Move down; target angle is pi.
    game.testJoystick.delta.setValues(0, 1);
    game.testJoystick.relativeDelta.setValues(0, 1);
    input.update(0.05);
    final angleAfterFirstUpdate = game.player.angle;

    // Should have started rotating but not reached the target.
    expect(angleAfterFirstUpdate, greaterThan(0));
    expect(angleAfterFirstUpdate, lessThan(math.pi));

    // Change direction upward before rotation completes.
    game.testJoystick.delta.setValues(0, -1);
    game.testJoystick.relativeDelta.setValues(0, -1);
    input.update(0.05);
    expect(game.player.angle, lessThan(angleAfterFirstUpdate));

    // Let it finish rotating to the new target.
    input.update(1);
    expect(game.player.angle, closeTo(0, 0.001));

    // Set a non-zero orientation and move the player away from center.
    game.player
      ..angle = 1
      ..position.setValues(20, 20);

    // Clear input before restarting.
    game.testJoystick.delta.setZero();
    game.testJoystick.relativeDelta.setZero();

    // Starting a new game should reset orientation and position.
    await game.startGame();
    game.onGameResize(Vector2.all(100));
    await game.ready();
    game.update(0);
    game.update(0);
    expect(game.player.angle, 0);
    expect(game.player.position, Vector2.zero());

    // After update with no input, angle and position should remain unchanged.
    game.update(0.1);
    expect(game.player.angle, 0);
    expect(game.player.position, Vector2.zero());
  });
}
