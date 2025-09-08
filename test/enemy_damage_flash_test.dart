import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/enemy.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

import 'test_joystick.dart';

class _FakeAudioService implements AudioService {
  final ValueNotifier<bool> muted = ValueNotifier(false);

  @override
  ValueNotifier<double> volume = ValueNotifier(1);

  @override
  double get masterVolume => 1;

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
  void setMasterVolume(double volume) {}

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.enemies, ...Assets.players]);
  });

  test('enemy flashes red when damaged', () async {
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(1000));
    await game.ready();

    final enemy = EnemyComponent()..reset(Vector2.zero());
    await game.add(enemy);
    game.update(0);

    expect(enemy.paint.colorFilter, isNull);

    enemy.takeDamage(0);
    expect(enemy.paint.colorFilter, isNotNull);

    game.update(Constants.playerDamageFlashDuration);
    expect(enemy.paint.colorFilter, isNull);
  });
}
