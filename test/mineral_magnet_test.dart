import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/mineral.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/constants.dart';

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    final keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = PlayerComponent(
      joystick: joystick,
      keyDispatcher: keyDispatcher,
      spritePath: Assets.players.first,
    );
    player.position = Vector2.zero();
    await add(player);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mineral moves toward player within magnet range', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    await game.ready();

    final start = Vector2(Constants.playerMagnetRange - 10, 0);
    final mineral = game.pools.acquire<MineralComponent>(
      (m) => m.reset(start.clone()),
    );
    await game.add(mineral);
    await game.ready();

    final before = mineral.position.clone();
    game.update(0.1);
    expect(mineral.position.x, lessThan(before.x));
  });

  test('mineral outside magnet range stays put', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    await game.ready();

    final start = Vector2(Constants.playerMagnetRange + 10, 0);
    final mineral = game.pools.acquire<MineralComponent>(
      (m) => m.reset(start.clone()),
    );
    await game.add(mineral);
    await game.ready();

    final before = mineral.position.clone();
    game.update(0.1);
    expect(mineral.position, equals(before));
  });
}
