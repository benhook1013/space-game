/// Centralised tunable values for the game.
class Constants {
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

  /// Starting health for the player.
  static const int playerMaxHealth = 3;

  /// Bullet travel speed in pixels per second.
  static const double bulletSpeed = 400;

  /// Bullet sprite size in logical pixels.
  static const double bulletSize = 8;

  /// Minimum time between player shots in seconds.
  static const double bulletCooldown = 0.2;

  /// Enemy movement speed in pixels per second.
  static const double enemySpeed = 100;

  /// Enemy sprite size in logical pixels.
  static const double enemySize = 32;

  /// Seconds between enemy spawns.
  static const double enemySpawnInterval = 2;

  /// Asteroid movement speed in pixels per second.
  static const double asteroidSpeed = 50;

  /// Asteroid sprite size in logical pixels.
  static const double asteroidSize = 24;

  /// Seconds between asteroid spawns.
  static const double asteroidSpawnInterval = 3;

  /// Score awarded for destroying an enemy.
  static const int enemyScore = 5;

  /// Score awarded for mining an asteroid.
  static const int asteroidScore = 1;

  /// Number of stars spawned per parallax layer.
  static const int starsPerLayer = 30;

  /// Speeds for starfield layers in pixels per second.
  static const double starSpeedSlow = 10;
  static const double starSpeedMedium = 20;
  static const double starSpeedFast = 40;

  /// Maximum star radius in logical pixels.
  static const double starMaxSize = 2;
}
