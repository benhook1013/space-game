import 'package:flame/components.dart';

/// Centralised tunable values for the game.
class Constants {
  /// Dimensions of the playable world in pixels.
  static final Vector2 worldSize = Vector2(2000, 2000);

  /// Player movement speed in pixels per second.
  static const double playerSpeed = 200;

  /// Player rotation speed in radians per second.
  static const double playerRotationSpeed = 10;

  /// Base player sprite size in logical pixels.
  static const double playerSize = 32;

  /// Scale applied to the player sprite size.
  static const double playerScale = 3;

  /// Maximum distance to auto-aim enemies when stationary, in pixels.
  static const double playerAutoAimRange = 300;

  /// Seconds between auto-aim direction updates when stationary.
  static const double playerAutoAimInterval = 0.2;

  /// Maximum distance to auto-mine asteroids, in pixels.
  static const double playerMiningRange = playerAutoAimRange;

  /// Damage dealt by each mining laser pulse.
  static const int miningPulseDamage = 1;

  /// Seconds between mining laser pulses.
  static const double miningPulseInterval = 0.5;

  /// Starting health for the player.
  static const int playerMaxHealth = 3;

  /// Bullet travel speed in pixels per second.
  static const double bulletSpeed = 400;

  /// Bullet sprite size in logical pixels.
  static const double bulletSize = 8;

  /// Minimum time between player shots in seconds.
  static const double bulletCooldown = 0.2;

  /// Damage dealt by player bullets.
  static const int bulletDamage = 1;

  /// Enemy movement speed in pixels per second.
  static const double enemySpeed = 100;

  /// Base enemy sprite size in logical pixels.
  static const double enemySize = 32;

  /// Scale applied to the enemy sprite size.
  static const double enemyScale = 3;

  /// Seconds between enemy spawns.
  static const double enemySpawnInterval = 2;

  /// Maximum health for an enemy.
  static const int enemyMaxHealth = 1;

  /// Asteroid movement speed in pixels per second.
  static const double asteroidSpeed = 50;

  /// Base asteroid sprite size in logical pixels.
  static const double asteroidSize = 24;

  /// Scale applied to the asteroid sprite size.
  static const double asteroidScale = 3;

  /// Minimum health for an asteroid.
  static const int asteroidMinHealth = 4;

  /// Maximum health for an asteroid.
  static const int asteroidMaxHealth = 6;

  /// Seconds between asteroid spawns.
  static const double asteroidSpawnInterval = 3;

  /// Score awarded for destroying an enemy.
  static const int enemyScore = 5;

  /// Score awarded for mining an asteroid.
  static const int asteroidScore = 1;

  /// Minerals gained for each hit on an asteroid.
  static const int asteroidMinerals = 1;

  /// Number of stars spawned per parallax layer.
  static const int starsPerLayer = 30;

  /// Speeds for starfield layers in pixels per second.
  static const double starSpeedSlow = 10;
  static const double starSpeedMedium = 20;
  static const double starSpeedFast = 40;

  /// Maximum star radius in logical pixels.
  static const double starMaxSize = 2;
}
