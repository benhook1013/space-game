import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/enemy.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/enemy_faction.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/game/game_state_machine.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/overlay_service.dart';
import 'package:space_game/services/storage_service.dart';

import 'test_joystick.dart';

class _FakeAudioService implements AudioService {
  @override
  final ValueNotifier<bool> muted = ValueNotifier(false);

  @override
  final ValueNotifier<double> volume = ValueNotifier(1);

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
  void setMasterVolume(double volume) {}

  @override
  void dispose() {}
}

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: Assets.players.first);

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
    overlayService = OverlayService(this);
    stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: () {},
      onPause: () {},
      onResume: () {},
      onGameOver: () {},
      onMenu: () {},
      onEnterUpgrades: () {},
      onExitUpgrades: () {},
    )..state = GameState.playing;

    keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    final joystick = TestJoystick();
    await add(joystick);
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late AudioService audio;
  late _TestGame game;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images
        .loadAll([...Assets.enemies, ...Assets.players, ...Assets.explosions]);

    storage = await StorageService.create();
    audio = _FakeAudioService();
    game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(1000));
    await game.ready();
  });

  test('enemy flashes red when damaged', () async {
    final enemy = EnemyComponent()
      ..reset(Vector2.zero(), EnemyFaction.faction1);
    await game.add(enemy);
    game.update(0);

    expect(enemy.paint.colorFilter, isNull);

    enemy.takeDamage(0);
    expect(enemy.paint.colorFilter, isNotNull);

    game.update(Constants.playerDamageFlashDuration);
    expect(enemy.paint.colorFilter, isNull);
  });

  test('player flashes red when hit', () {
    expect(game.player.paint.colorFilter, isNull);

    game.hitPlayer();
    expect(game.player.paint.colorFilter, isNotNull);

    game.update(Constants.playerDamageFlashDuration);
    expect(game.player.paint.colorFilter, isNull);
  });
}
