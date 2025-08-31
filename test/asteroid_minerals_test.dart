import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/assets.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mining asteroid increases minerals', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll(Assets.asteroids);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final asteroid = game.acquireAsteroid(Vector2.zero(), Vector2.zero());
    await game.add(asteroid);
    final initial = game.minerals.value;
    asteroid.takeDamage(1);
    expect(game.minerals.value, initial + Constants.asteroidMinerals);
    game.releaseAsteroid(asteroid);
  });

  test('bullet damage does not increase minerals', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll(Assets.asteroids);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final asteroid = game.acquireAsteroid(Vector2.zero(), Vector2.zero());
    await game.add(asteroid);
    final initial = game.minerals.value;
    asteroid.takeDamage(1, awardMinerals: false);
    expect(game.minerals.value, initial);
    game.releaseAsteroid(asteroid);
  });
}
