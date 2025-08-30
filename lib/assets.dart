import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

/// Central registry for asset paths and preloading.
class Assets {
  // Flame automatically prefixes these with `assets/images/` when loading.
  static const String player = 'player.png';
  static const List<String> enemies = [
    'enemies/enemy1.png',
    'enemies/enemy2.png',
    'enemies/enemy3.png',
    'enemies/enemy4.png',
  ];
  static const String asteroid = 'asteroid.png';
  static const String bullet = 'bullet.png';

  // FlameAudio uses `assets/audio/` as the default base path.
  static const String shootSfx = 'shoot.wav';

  /// Preloads all images and audio assets.
  static Future<void> load() async {
    await Flame.images.loadAll([
      player,
      asteroid,
      bullet,
      ...enemies,
    ]);

    await FlameAudio.audioCache.loadAll([shootSfx]);
  }

  static final Random _rand = Random();

  /// Returns a random enemy sprite path.
  static String randomEnemy() => enemies[_rand.nextInt(enemies.length)];
}
