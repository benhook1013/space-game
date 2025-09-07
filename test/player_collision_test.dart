import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/components/enemy.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/game_state_machine.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/overlay_service.dart';

import 'test_joystick.dart';

class _FakeAudioService implements AudioService {
  @override
  final ValueNotifier<bool> muted = ValueNotifier(false);
  double _masterVolume = 1;

  @override
  double get masterVolume => _masterVolume;

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
    _masterVolume = volume;
  }
}

class _FakeOverlayService implements OverlayService {
  @override
  final Game game = FlameGame();

  @override
  void showHud() {}

  @override
  void showPause() {}

  @override
  void showGameOver() {}

  @override
  void showMenu() {}

  @override
  void showHelp() {}

  @override
  void hideHelp() {}

  @override
  void showUpgrades() {}

  @override
  void hideUpgrades() {}

  @override
  void showSettings() {}

  @override
  void hideSettings() {}
}

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: Assets.players.first);

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
    overlayService = _FakeOverlayService();
    stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: () {},
      onPause: () {},
      onResume: () {},
      onGameOver: () {},
      onMenu: () {},
    );
    stateMachine.state = GameState.playing;
    final dispatcher = KeyDispatcher();
    await add(dispatcher);
    joystick = TestJoystick();
    await add(joystick);
    player = _TestPlayer(joystick: joystick, keyDispatcher: dispatcher);
    await add(player);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([
      ...Assets.players,
      ...Assets.enemies,
      ...Assets.asteroids,
    ]);
  });

  test('colliding with enemy reduces health and removes enemy', () async {
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
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

    final enemy = game.pools.acquire<EnemyComponent>(
      (e) => e.reset(game.player.position.clone()),
    );
    await game.add(enemy);
    game.update(0);

    final initialHealth = game.scoreService.health.value;
    game.player.onCollisionStart({}, enemy);
    game.update(0);

    expect(game.scoreService.health.value, initialHealth - 1);
    expect(enemy.parent, isNull);
  });

  test('colliding with asteroid reduces health and removes asteroid', () async {
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
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

    final asteroid = game.pools.acquire<AsteroidComponent>(
      (a) => a.reset(game.player.position.clone(), Vector2.zero()),
    );
    await game.add(asteroid);
    game.update(0);

    final initialHealth = game.scoreService.health.value;
    game.player.onCollisionStart({}, asteroid);
    game.update(0);

    expect(game.scoreService.health.value, initialHealth - 1);
    expect(asteroid.parent, isNull);
  });
}
