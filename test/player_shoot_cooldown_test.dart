import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/bullet.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

class _TestBullet extends BulletComponent {
  @override
  Future<void> onLoad() async {}
}

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  @override
  Future<void> onLoad() async {}
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  final List<_TestBullet> _pool = [];

  @override
  BulletComponent acquireBullet(Vector2 position, Vector2 direction) {
    final bullet = _pool.isNotEmpty ? _pool.removeLast() : _TestBullet();
    bullet.reset(position, direction);
    return bullet;
  }

  @override
  void releaseBullet(BulletComponent bullet) {
    _pool.add(bullet as _TestBullet);
  }

  @override
  Future<void> onLoad() async {
    final keyDispatcher = KeyDispatcher();
    add(keyDispatcher);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    add(player);
    onGameResize(
      Vector2.all(Constants.playerSize *
          (Constants.spriteScale + Constants.playerScale) *
          2),
    );
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

    game.player.shoot();
    game.update(0);
    expect(game.children.whereType<BulletComponent>().length, 1);

    game.player.shoot();
    game.update(0);
    expect(game.children.whereType<BulletComponent>().length, 1);

    game.player.update(Constants.bulletCooldown);
    game.player.shoot();
    game.update(0);
    expect(game.children.whereType<BulletComponent>().length, 2);
  });
}
