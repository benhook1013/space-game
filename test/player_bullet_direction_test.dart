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
import 'dart:math' as math;
import 'test_joystick.dart';

class _TestBullet extends BulletComponent {
  @override
  Future<void> onLoad() async {}
}

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  @override
  void shoot() {
    final direction = Vector2(
      math.cos(angle - math.pi / 2),
      math.sin(angle - math.pi / 2),
    );
    final bullet = game.pools.acquire<BulletComponent>(
      (b) => b.reset(position.clone(), direction),
    );
    game.add(bullet);
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
    joystick = TestJoystick();
    await add(joystick);
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bullet fires in direction of ship orientation', () async {
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
    game.update(0);
    game.update(0);
    audio.muted.value = true;

    game.player.angle = math.pi / 2; // face right
    game.player.shoot();
    game.update(0);
    final bullet = game.children.whereType<BulletComponent>().first;
    final start = bullet.position.clone();

    game.update(0.1);
    expect(bullet.position.x, greaterThan(start.x));
    expect((bullet.position.y - start.y).abs(), lessThan(0.001));
  });
}
