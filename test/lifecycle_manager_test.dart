import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/bullet.dart';

import 'helpers/lifecycle_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onStart resets state and onGameOver stops spawners', () async {
    SharedPreferences.setMockInitialValues({});
    await loadLifecycleTestImages();
    final game = await createLifecycleTestGame(viewportSize: 200);
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
