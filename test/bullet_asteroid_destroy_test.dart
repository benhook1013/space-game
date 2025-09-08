import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/components/bullet.dart';
import 'package:space_game/components/mineral.dart';
import 'package:space_game/components/explosion.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

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
  Future<void> toggleMute() async {
    muted.value = !muted.value;
  }

  @override
  void setMasterVolume(double volume) {
    this.volume.value = volume;
  }

  @override
  void dispose() {}
}

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
    joystick = TestJoystick();
    await add(joystick);
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bullet destroys asteroid without minerals or explosion', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([
      ...Assets.asteroids,
      Assets.bullet,
      ...Assets.players,
    ]);
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(500));
    await game.ready();

    final asteroid = game.pools.acquire<AsteroidComponent>(
      (a) => a.reset(Vector2.zero(), Vector2.zero()),
    );
    await game.add(asteroid);
    final bullet = BulletComponent()..reset(Vector2.zero(), Vector2(1, 0));
    await game.add(bullet);
    game.update(0);

    bullet.onCollisionStart({}, asteroid);
    game.update(0);

    expect(asteroid.parent, isNull);
    expect(bullet.parent, isNull);
    expect(game.pools.components<MineralComponent>(), isEmpty);
    expect(game.children.whereType<ExplosionComponent>(), isEmpty);
    expect(game.score.value, Constants.asteroidScore);
  });
}
