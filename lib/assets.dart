import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

/// Central registry for asset paths and preloading.
class Assets {
  // Flame automatically prefixes these with `assets/images/` when loading.
  static const List<String> players = [
    'players/player1.png',
    'players/player2.png',
  ];
  static const List<String> enemies = [
    'enemies/enemy1.png',
    'enemies/enemy2.png',
    'enemies/enemy3.png',
    'enemies/enemy4.png',
  ];
  static const List<String> asteroids = [
    'asteroids/asteroid1.png',
    'asteroids/asteroid2.png',
    'asteroids/asteroid3.png',
    'asteroids/asteroid4.png',
    'asteroids/asteroid5.png',
  ];
  static const String bullet = 'bullet.png';
  static const String mineralIcon = 'icons/mineral.png';

  // FlameAudio uses `assets/audio/` as the default base path.
  static const String shootSfx = 'shoot.wav';

  /// Preloads all images and audio assets.
  static Future<void> load() async {
    await Flame.images.loadAll([
      ...players,
      ...enemies,
      ...asteroids,
      bullet,
      mineralIcon,
    ]);

    await FlameAudio.audioCache.loadAll([shootSfx]);
  }

  static final Random _rand = Random();

  /// Returns a random enemy sprite path.
  static String randomEnemy() => enemies[_rand.nextInt(enemies.length)];

  /// Returns a random asteroid sprite path.
  static String randomAsteroid() => asteroids[_rand.nextInt(asteroids.length)];
}
