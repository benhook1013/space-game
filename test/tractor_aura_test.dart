import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/mineral.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/game/event_bus.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    final keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    final joystick = JoystickComponent(
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

  test('pickup moves toward player within Tractor Aura radius', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    await game.ready();
    game.onGameResize(Vector2.all(100));
    game.eventBus.emit(ComponentSpawnEvent<PlayerComponent>(game.player));
    game.update(0);
    game.update(0);

    final start = Vector2(game.upgradeService.tractorRange - 10, 0);
    final pickup = game.pools.acquire<MineralComponent>(
      (m) => m.reset(start.clone()),
    );
    await game.add(pickup);
    await game.ready();
    game.update(0);
    game.update(0);

    final before = pickup.position.clone();
    game.update(0.1);
    expect(pickup.position.x, lessThan(before.x));
  });

  test('pickup outside Tractor Aura radius stays put', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    await game.ready();
    game.onGameResize(Vector2.all(100));
    game.eventBus.emit(ComponentSpawnEvent<PlayerComponent>(game.player));
    game.update(0);
    game.update(0);

    final start = Vector2(game.upgradeService.tractorRange + 10, 0);
    final pickup = game.pools.acquire<MineralComponent>(
      (m) => m.reset(start.clone()),
    );
    await game.add(pickup);
    await game.ready();
    game.update(0);
    game.update(0);

    final before = pickup.position.clone();
    game.update(0.1);
    expect(pickup.position, equals(before));
  });

  test('Tractor Booster upgrade extends pull radius', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();
    await game.ready();
    game.onGameResize(Vector2.all(100));
    game.eventBus.emit(ComponentSpawnEvent<PlayerComponent>(game.player));
    game.update(0);
    game.update(0);

    final baseRange = game.upgradeService.tractorRange;
    final start = Vector2(baseRange + 10, 0);
    final pickup = game.pools.acquire<MineralComponent>(
      (m) => m.reset(start.clone()),
    );
    await game.add(pickup);
    await game.ready();
    game.update(0);
    game.update(0);

    final upgrade =
        game.upgradeService.upgrades.firstWhere((u) => u.id == 'tractorRange1');
    game.scoreService.addMinerals(upgrade.cost);
    game.upgradeService.buy(upgrade);

    final before = pickup.position.clone();
    game.update(0.1);
    expect(pickup.position.x, lessThan(before.x));
  });
}
