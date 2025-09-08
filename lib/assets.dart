import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

import 'enemy_faction.dart';

/// Central registry for asset paths and preloading.
class Assets {
  // Flame automatically prefixes these with `assets/images/` when loading.
  static const List<String> players = [
    'players/player1.png',
    'players/player2.png',
  ];
  static const Map<EnemyFaction, List<String>> enemyFactions = {
    EnemyFaction.faction1: ['enemies/faction1/unit.png'],
    EnemyFaction.faction2: ['enemies/faction2/unit.png'],
    EnemyFaction.faction3: ['enemies/faction3/unit.png'],
    EnemyFaction.faction4: ['enemies/faction4/unit.png'],
  };

  static List<String> get enemies =>
      enemyFactions.values.expand((e) => e).toList();
  static const List<String> asteroids = [
    'asteroids/asteroid1.png',
    'asteroids/asteroid2.png',
    'asteroids/asteroid3.png',
    'asteroids/asteroid4.png',
    'asteroids/asteroid5.png',
  ];
  static const List<String> explosions = [
    'explosions/explosion1.png',
    'explosions/explosion2.png',
    'explosions/explosion3.png',
  ];
  static const String bullet = 'bullet.png';
  static const String mineralIcon = 'icons/mineral.png';
  static const String scoreIcon = 'icons/score.png';
  static const String healthIcon = 'icons/health.png';
  static const String settingsIcon = 'icons/settings.png';

  // FlameAudio uses `assets/audio/` as the default base path.
  static const String shootSfx = 'laser-bullet.mp3';
  static const String explosionSfx = 'explosion.mp3';
  static const String miningLaserSfx = 'mining-laser-continuous.mp3';

  /// Preloads all images and audio assets.
  static Future<void> load() async {
    await Flame.images.loadAll([
      ...players,
      ...enemies,
      ...asteroids,
      ...explosions,
      bullet,
      mineralIcon,
      scoreIcon,
      healthIcon,
      settingsIcon,
    ]);

    await FlameAudio.audioCache
        .loadAll([shootSfx, explosionSfx, miningLaserSfx]);
  }

  static final Random _rand = Random();

  /// Returns a random faction.
  static EnemyFaction randomFaction() =>
      EnemyFaction.values[_rand.nextInt(EnemyFaction.values.length)];

  /// Returns a random enemy sprite path for [faction].
  static String randomEnemyForFaction(EnemyFaction faction) {
    final sprites = enemyFactions[faction]!;
    return sprites[_rand.nextInt(sprites.length)];
  }

  /// Returns a random asteroid sprite path.
  static String randomAsteroid() => asteroids[_rand.nextInt(asteroids.length)];
}
