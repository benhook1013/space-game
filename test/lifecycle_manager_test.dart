import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_game/assets.dart';
import 'package:space_game/components/bullet.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/menu_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onStart resets state and onGameOver stops spawners', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([
      ...Assets.players,
      ...Assets.enemies,
      ...Assets.asteroids,
      ...Assets.explosions,
      Assets.bullet,
    ]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(200));
    await game.ready();

    game.scoreService.score.value = 10;
    final bullet = game.pools.acquire<BulletComponent>(
      (b) => b.reset(Vector2.zero(), Vector2.zero()),
    );
    await game.add(bullet);
    await game.ready();
    game.pauseEngine();

    game.lifecycle.onStart();
    await game.ready();

    expect(game.paused, isFalse);
    expect(game.scoreService.score.value, 0);
    expect(game.pools.components<BulletComponent>(), isEmpty);

    expect(game.enemySpawner.isRunning, isTrue);

    game.lifecycle.onGameOver();
    expect(game.paused, isTrue);
    expect(game.enemySpawner.isRunning, isFalse);
  });
}
