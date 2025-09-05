import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/player.dart';
import 'package:space_game/components/offscreen_cleanup.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

import 'test_joystick.dart';
import 'package:space_game/assets.dart';
import 'package:flame/flame.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: Assets.players.first);

  @override
  Future<void> onLoad() async {}
}

class _CleanupComponent extends PositionComponent
    with HasGameReference<SpaceGame>, OffscreenCleanup {
  _CleanupComponent(Vector2 position) {
    this.position.setFrom(position);
    size = Vector2.all(10);
  }

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
    await Flame.images.loadAll([...Assets.players]);
  });

  test('removes components beyond despawn radius', () async {
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(1000));
    await game.ready();

    final comp = _CleanupComponent(Vector2(Constants.despawnRadius + 10, 0));
    await game.add(comp);
    game.update(0);
    await game.ready();
    expect(comp.parent, isNull);
  });

  test('retains components within despawn radius', () async {
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    game.onGameResize(Vector2.all(1000));
    await game.ready();

    final comp = _CleanupComponent(Vector2(Constants.despawnRadius - 10, 0));
    await game.add(comp);
    game.update(0);
    await game.ready();
    expect(comp.parent, isNotNull);
  });
}
