import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/bullet.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/pool_manager.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'test_joystick.dart';

class _TestBullet extends BulletComponent {
  @override
  Future<void> onLoad() async {}
}

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  double _cooldown = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _cooldown = math.max(0, _cooldown - dt);
  }

  @override
  void shoot() {
    if (_cooldown > 0) {
      return;
    }
    final direction = Vector2(
      math.cos(angle - math.pi / 2),
      math.sin(angle - math.pi / 2),
    );
    final bullet = game.pools.acquire<BulletComponent>(
      (b) => b.reset(position.clone(), direction),
    );
    game.add(bullet);
    _cooldown = Constants.bulletCooldown;
  }
}

class _TestPoolManager extends PoolManager {
  _TestPoolManager({required super.events});

  final List<_TestBullet> _pool = [];

  @override
  T acquire<T extends Component>(void Function(T) reset) {
    if (T == BulletComponent) {
      final bullet = _pool.isNotEmpty ? _pool.removeLast() : _TestBullet();
      reset(bullet as T);
      return bullet as T;
    }
    return super.acquire<T>(reset);
  }

  @override
  void release<T extends Component>(T component) {
    if (component is BulletComponent) {
      _pool.add(component as _TestBullet);
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
    final keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    await controlManager.init();
    controlManager.joystick.removeFromParent();
    controlManager.joystick = TestJoystick();
    await add(controlManager.joystick);
    player = _TestPlayer(
      joystick: controlManager.joystick,
      keyDispatcher: keyDispatcher,
    );
    await add(player);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player shooting respects cooldown', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
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
    game.controlManager.joystick.onGameResize(game.size);
    game.update(0);
    game.update(0);

    game.player.shoot();
    game.update(0);
    expect(game.children.whereType<BulletComponent>().length, 1);

    game.player.shoot();
    game.update(0);
    expect(game.children.whereType<BulletComponent>().length, 1);

    game.update(Constants.bulletCooldown);
    game.player.shoot();
    game.update(0);
    expect(game.children.whereType<BulletComponent>().length, 2);
  });
}
