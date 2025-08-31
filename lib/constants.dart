import 'package:flame/components.dart';

/// Centralised tunable values for the game.
class Constants {
  /// Dimensions of the playable world in pixels.
  static final Vector2 worldSize = Vector2(2000, 2000);

  /// Player movement speed in pixels per second.
  static const double playerSpeed = 200;

  /// Player rotation speed in radians per second.
  static const double playerRotationSpeed = 10;

  /// Default scale multiplier applied to most sprites.
  static const double spriteScale = 3;

  /// Base player sprite size in logical pixels.
  static const double playerSize = 32;

  /// Extra scale applied on top of [spriteScale] for the player sprite.
  static const double playerScale = 0;

  /// Maximum distance to auto-aim enemies when stationary, in pixels.
  static const double playerAutoAimRange = 300;

  /// Maximum distance to auto-mine asteroids, in pixels.
  static const double playerMiningRange = playerAutoAimRange;

  /// Damage dealt by each mining laser pulse.
  static const int miningPulseDamage = 1;

  /// Seconds between mining laser pulses.
  static const double miningPulseInterval = 0.5;

  /// Starting health for the player.
  static const int playerMaxHealth = 3;

  /// Seconds that the player sprite flashes red after taking damage.
  static const double playerDamageFlashDuration = 0.2;

  /// Radius of the player's mineral attractor field in pixels.
  static const double playerMagnetRange = 150;

  /// Speed minerals move toward the player within the attractor field.
  static const double mineralMagnetSpeed = 200;

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

  /// Extra scale applied on top of [spriteScale] for enemy sprites.
  static const double enemyScale = 0;

  /// Seconds between enemy spawns.
  static const double enemySpawnInterval = 2;

  /// Maximum health for an enemy.
  static const int enemyMaxHealth = 1;

  /// Asteroid movement speed in pixels per second.
  static const double asteroidSpeed = 50;

  /// Base asteroid sprite size in logical pixels.
  static const double asteroidSize = 24;

  /// Extra scale applied on top of [spriteScale] for asteroid sprites.
  static const double asteroidScale = 0;

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

  /// Minerals granted by a single mineral pickup.
  static const int asteroidMinerals = 1;

  /// Base mineral pickup sprite size in logical pixels.
  static const double mineralSize = 16;

  /// Extra scale applied on top of [spriteScale] for mineral sprites.
  static const double mineralScale = 0;

  /// Distance from an asteroid where mineral drops may appear.
  static const double mineralDropRadius = 16;

  /// Number of stars spawned per parallax layer.
  static const int starsPerLayer = 30;

  /// Speeds for starfield layers in pixels per second.
  static const double starSpeedSlow = 10;
  static const double starSpeedMedium = 20;
  static const double starSpeedFast = 40;

  /// Maximum star radius in logical pixels.
  static const double starMaxSize = 2;
}
