import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/bullet.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/pool_manager.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/game_state_machine.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/services/overlay_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/audio_service.dart';

import 'test_joystick.dart';

class _TestBullet extends BulletComponent {
  @override
  Future<void> onLoad() async {}
}

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

class _TestPoolManager extends PoolManager {
  _TestPoolManager({required super.events});

  final List<_TestBullet> _bullets = [];

  @override
  T acquire<T extends Component>(void Function(T) reset) {
    if (T == BulletComponent) {
      final bullet =
          _bullets.isNotEmpty ? _bullets.removeLast() : _TestBullet();
      reset(bullet as T);
      return bullet as T;
    }
    return super.acquire<T>(reset);
  }

  @override
  void release<T extends Component>(T component) {
    if (component is BulletComponent) {
      _bullets.add(component as _TestBullet);
      return;
    }
    super.release(component);
  }
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  PoolManager createPoolManager() => _TestPoolManager(events: eventBus);

  @override
  Future<void> onLoad() async {
    keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    joystick = TestJoystick();
    await add(joystick);
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
    overlayService = OverlayService(this);
    stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: () {},
      onPause: pauseEngine,
      onResume: resumeEngine,
      onGameOver: () {},
      onMenu: () {},
      onEnterUpgrades: () {},
      onExitUpgrades: () {},
    );
    player.inputBehavior.game = this;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('keyboard movement when joystick idle', () async {
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(500));
    await game.ready();

    game.keyDispatcher.onKeyEvent(
      const KeyDownEvent(
        logicalKey: LogicalKeyboardKey.keyW,
        physicalKey: PhysicalKeyboardKey.keyW,
        timeStamp: Duration.zero,
      ),
      {LogicalKeyboardKey.keyW},
    );
    game.player.inputBehavior.update(1);
    expect(game.player.position.y, lessThan(0));
  });

  test('joystick movement overrides keyboard', () async {
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(500));
    await game.ready();

    game.keyDispatcher.onKeyEvent(
      const KeyDownEvent(
        logicalKey: LogicalKeyboardKey.keyW,
        physicalKey: PhysicalKeyboardKey.keyW,
        timeStamp: Duration.zero,
      ),
      {LogicalKeyboardKey.keyW},
    );
    game.joystick.delta.setValues(1, 0);
    game.joystick.relativeDelta.setValues(1, 0);
    game.player.inputBehavior.update(1);
    expect(game.player.position.x, greaterThan(0));
    expect(game.player.position.y, closeTo(0, 0.001));
  });

  test('continuous shooting fires repeatedly', () async {
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(500));
    await game.ready();

    game.stateMachine.state = GameState.playing;
    game.player.startShooting();
    game.player.inputBehavior.update(0);
    expect(game.children.whereType<BulletComponent>().length, 1);

    game.player.inputBehavior.update(Constants.bulletCooldown);
    expect(game.children.whereType<BulletComponent>().length, 2);

    game.player.stopShooting();
    game.player.inputBehavior.update(Constants.bulletCooldown);
    expect(game.children.whereType<BulletComponent>().length, 2);
  });

  test('speed upgrade increases movement distance', () async {
    final storage = await StorageService.create();
    final audio = _FakeAudioService();
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(500));
    await game.ready();

    game.joystick.delta.setValues(1, 0);
    game.joystick.relativeDelta.setValues(1, 0);
    game.player.inputBehavior.update(1);
    final normalX = game.player.position.x;

    game.player.position.setZero();
    final upgrade =
        game.upgradeService.upgrades.firstWhere((u) => u.id == 'speed1');
    game.scoreService.addMinerals(upgrade.cost);
    game.upgradeService.buy(upgrade);
    game.joystick.delta.setValues(1, 0);
    game.joystick.relativeDelta.setValues(1, 0);
    game.player.inputBehavior.update(1);
    expect(game.player.position.x, greaterThan(normalX));
  });
}
