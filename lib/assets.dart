import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';

import 'enemy_faction.dart';
import 'log.dart';

/// Central registry for asset paths and preloading.
class Assets {
  // Flame automatically prefixes these with `assets/images/` when loading.
  static const List<String> players = [
    'players/player1.png',
    'players/player2.png',
  ];
  static final Map<EnemyFaction, EnemySpriteSet> enemyFactions = {
    for (final faction in EnemyFaction.values)
      faction: EnemySpriteSet(
        units: [_enemyPath(faction, 'unit.png')],
        boss: _enemyPath(faction, 'boss.png'),
      ),
  };

  static String _enemyPath(EnemyFaction faction, String file) =>
      'enemies/${faction.name}/$file';

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

  /// Preloads remaining images and all audio assets.
  ///
  /// The optional [onProgress] callback reports a value between `0` and `1`
  /// after each asset finishes loading.
  static Future<void> loadRemaining({
    void Function(double progress)? onProgress,
  }) async {
    final imagePaths = [
      ...asteroids.skip(1),
      ...explosions.skip(1),
      ...enemies,
    ];
    const audioPaths = [shootSfx, explosionSfx, miningLaserSfx];

    final total = imagePaths.length + audioPaths.length;
    var loaded = 0;

    Future<void> track(
      Future<void> Function(String path) loader,
      String path,
    ) async {
      await loader(path);
      loaded++;
      onProgress?.call(loaded / total);
    }

    await Future.wait([
      ...imagePaths.map((p) => track(_loadImage, p)),
      ...audioPaths.map((p) => track(_loadAudio, p)),
    ]);
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
    } on MissingPluginException catch (e) {
      // Some test environments lack the necessary platform channels.
      log('Missing audio plugin for $path: $e');
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
