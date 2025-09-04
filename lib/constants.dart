/// Centralised tunable values for the game.
class Constants {
  /// Distance from the player after which entities are removed.
  static const double despawnRadius = 1500;

  /// Size of a single generated starfield tile in pixels.
  static const double starfieldTileSize = 512;

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

  /// Multiplier applied to [miningPulseInterval] when the mining speed
  /// upgrade is purchased.
  static const double miningPulseIntervalUpgradeFactor = 0.8;

  /// Volume for the mining laser sound effect (0-1).
  static const double miningLaserVolume = 0.25;

  /// Volume multiplier used when audio is dimmed instead of muted on pause.
  static const double pausedAudioVolumeFactor = 0.2;

  /// Starting health for the player.
  static const int playerMaxHealth = 3;

  /// Seconds that the player sprite flashes red after taking damage.
  static const double playerDamageFlashDuration = 0.2;

  /// Radius of the player's Tractor Aura in pixels.
  static const double playerTractorAuraRadius = 150;

  /// Speed pickups move toward the player within the Tractor Aura.
  static const double tractorAuraPullSpeed = 200;

  /// Bullet travel speed in pixels per second.
  static const double bulletSpeed = 400;

  /// Bullet sprite size in logical pixels.
  static const double bulletSize = 8;

  /// Minimum time between player shots in seconds.
  static const double bulletCooldown = 0.2;

  /// Multiplier applied to [bulletCooldown] when the fire rate upgrade is
  /// purchased.
  static const double bulletCooldownUpgradeFactor = 0.8;

  /// Damage dealt by player bullets.
  static const int bulletDamage = 1;

  /// Base explosion sprite size in logical pixels.
  static const double explosionSize = 32;

  /// Extra scale applied on top of [spriteScale] for explosion sprites.
  static const double explosionScale = 0;

  /// Duration of each explosion animation frame in seconds.
  static const double explosionFrameDuration = 0.05;

  /// Seconds an explosion stays on screen before being removed.
  static const double explosionLifetime = 2;

  /// Enemy movement speed in pixels per second.
  static const double enemySpeed = 100;

  /// Base enemy sprite size in logical pixels.
  static const double enemySize = 32;

  /// Extra scale applied on top of [spriteScale] for enemy sprites.
  static const double enemyScale = 0;

  /// Seconds between enemy spawns.
  static const double enemySpawnInterval = 2;

  /// Number of enemies spawned at once.
  static const int enemyGroupSize = 3;

  /// Maximum random offset for enemies within a spawn group.
  static const double enemyGroupSpread = 40;

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

  /// Maximum number of minerals spawned per damage instance on an asteroid.
  static const int asteroidMineralDropMax = 3;

  /// Base mineral pickup sprite size in logical pixels.
  static const double mineralSize = 16;

  /// Extra scale applied on top of [spriteScale] for mineral sprites.
  static const double mineralScale = 0;

  /// Distance from an asteroid where mineral drops may appear.
  static const double mineralDropRadius = 16;

  /// Cell size for spatial grid used in proximity queries.
  static const double spatialGridCellSize = 200;

  /// Number of stars spawned per parallax layer.
  static const int starsPerLayer = 30;

  /// Speeds for starfield layers in pixels per second.
  static const double starSpeedSlow = 10;
  static const double starSpeedMedium = 20;
  static const double starSpeedFast = 40;

  /// Maximum star radius in logical pixels.
  static const double starMaxSize = 2;
}
