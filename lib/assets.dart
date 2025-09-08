import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

import 'enemy_faction.dart';
import 'log.dart';

/// Central registry for asset paths and preloading.
class Assets {
  // Flame automatically prefixes these with `assets/images/` when loading.
  static const List<String> players = [
    'players/player1.png',
    'players/player2.png',
  ];
  static const Map<EnemyFaction, EnemySpriteSet> enemyFactions = {
    EnemyFaction.faction1: EnemySpriteSet(
      units: ['enemies/faction1/unit.png'],
      boss: 'enemies/faction1/unit.png',
    ),
    EnemyFaction.faction2: EnemySpriteSet(
      units: ['enemies/faction2/unit.png'],
      boss: 'enemies/faction2/unit.png',
    ),
    EnemyFaction.faction3: EnemySpriteSet(
      units: ['enemies/faction3/unit.png'],
      boss: 'enemies/faction3/unit.png',
    ),
    EnemyFaction.faction4: EnemySpriteSet(
      units: ['enemies/faction4/unit.png'],
      boss: 'enemies/faction4/unit.png',
    ),
  };

  static List<String> get enemies =>
      enemyFactions.values.expand((e) => [...e.units, e.boss]).toList();
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

  /// Preloads only the assets required for the initial menu/level.
  static Future<void> loadEssential() async {
    final imagePaths = [
      ...players,
      asteroids.first,
      explosions.first,
      bullet,
      mineralIcon,
      scoreIcon,
      healthIcon,
      settingsIcon,
    ];
    await Future.wait(imagePaths.map(_loadImage));
  }

  /// Preloads remaining images and all audio assets in the background.
  static Future<void> loadRemaining() async {
    final imagePaths = [
      ...asteroids.skip(1),
      ...explosions.skip(1),
      ...enemies,
    ];
    await Future.wait(imagePaths.map(_loadImage));

    const audioPaths = [shootSfx, explosionSfx, miningLaserSfx];
    await Future.wait(audioPaths.map(_loadAudio));
  }

  static Future<void> _loadImage(String path) async {
    try {
      await Flame.images.load(path);
    } catch (e) {
      log('Failed to load image asset $path: $e');
      rethrow;
    }
  }

  static Future<void> _loadAudio(String path) async {
    try {
      await FlameAudio.audioCache.load(path);
    } catch (e) {
      log('Failed to load audio asset $path: $e');
      rethrow;
    }
  }

  static final Random _rand = Random();

  /// Returns a random faction.
  static EnemyFaction randomFaction() =>
      EnemyFaction.values[_rand.nextInt(EnemyFaction.values.length)];

  /// Returns a random unit sprite path for [faction].
  static String randomUnitForFaction(EnemyFaction faction) {
    final sprites = enemyFactions[faction]!.units;
    return sprites[_rand.nextInt(sprites.length)];
  }

  /// Returns the boss sprite path for [faction].
  static String bossForFaction(EnemyFaction faction) =>
      enemyFactions[faction]!.boss;

  /// Returns a random asteroid sprite path.
  static String randomAsteroid() => asteroids[_rand.nextInt(asteroids.length)];
}

class EnemySpriteSet {
  const EnemySpriteSet({required this.units, required this.boss});

  /// Sprite paths for standard units belonging to a faction.
  final List<String> units;

  /// Sprite path for the faction's boss unit.
  final String boss;
}
