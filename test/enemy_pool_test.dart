import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flame/flame.dart';
import 'package:space_game/assets.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:flame/components.dart';
import 'package:space_game/components/enemy.dart';
import 'package:space_game/enemy_faction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enemy instances are reused from pool', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll(Assets.enemies);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final enemy1 = game.pools.acquire<EnemyComponent>(
      (e) => e.reset(Vector2.zero(), EnemyFaction.faction1),
    );
    game.pools.release(enemy1);
    final enemy2 = game.pools.acquire<EnemyComponent>(
      (e) => e.reset(Vector2.zero(), EnemyFaction.faction1),
    );
    expect(identical(enemy1, enemy2), isTrue);
  });
}
