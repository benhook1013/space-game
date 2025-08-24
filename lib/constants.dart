/// Centralised tunable values for the game.
class Constants {
  /// Logical resolution used for the game viewport.
  static const double logicalWidth = 360;
  static const double logicalHeight = 640;

  /// Player movement speed in pixels per second.
  static const double playerSpeed = 200;

  /// Player sprite size in logical pixels.
  static const double playerSize = 32;

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

  /// Asteroid movement speed in pixels per second.
  static const double asteroidSpeed = 50;

  /// Asteroid sprite size in logical pixels.
  static const double asteroidSize = 24;

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
