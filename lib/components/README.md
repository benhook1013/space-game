# components/

Gameplay entities and reusable pieces.

- Includes player, enemy, asteroid, bullet and mineral pickup
  components.
- Each extends a Flame component and mixes in `HasGameReference<SpaceGame>`
  when it needs game context.
- Use simple hit boxes like `CircleHitbox` or `RectangleHitbox` with
  `HasCollisionDetection` on the game.
- Shared mixins like `DebugHealthText` and `DamageFlash` provide common
  behaviours such as rendering health values in debug mode or flashing sprites
  when taking damage.
- Pull tunable values from `constants.dart` and asset references from
  `assets.dart`.
- Bullet, asteroid and enemy components use small object pools to reduce
  garbage collection, and unit tests confirm pooled instances are reused.
- Give components deterministic IDs to support future multiplayer sync.
- Update movement and timers using the `dt` value for frame-rate independence.

## Implemented Components

- [PlayerComponent](player.md) – moves via joystick or keyboard, fires bullets
  with a short cooldown and tracks health.
- [EnemyComponent](enemy.md) – drifts toward the player with a single health
  point and awards score when defeated.
- [BulletComponent](bullet.md) – short-lived projectile that deals one damage
  and is destroyed on hit or when leaving the screen.
- [AsteroidComponent](asteroid.md) – floats randomly, requires four to six
  damage pulses and drops a mineral pickup for each point of damage.
- [MiningLaserComponent](mining_laser.md) – auto-targets and mines nearby
  asteroids with a widening pulse beam.
- [MineralComponent](mineral.md) – collectible dropped whenever an asteroid is
  damaged that increases the player's mineral total when picked up.
- Each mineral independently homes toward the player when within the Tractor
  Aura, removing the need for a separate component.
- [Starfield](starfield.md) – deterministic world-space background that caches
  star tiles and prunes those far from the camera.
- [ExplosionComponent](explosion.md) – short animation and sound played when
  a ship is destroyed.
- `EnemySpawner` – releases timed groups of enemies ahead of the player.
- `AsteroidSpawner` – scatters asteroids around the player as they travel.
- `PlayerInputBehavior` – handles joystick and keyboard input for the player.
- `AutoAimBehavior` – rotates the player toward the nearest enemy when idle.
- `TractorAuraRenderer` – draws a radial gradient showing the Tractor Aura.
- `OffscreenCleanup` – mixin that removes components far from the camera.
- `SpawnRemoveEmitter` – mixin emitting spawn/remove events for pooling.
- `Damageable` – mixin tracking hit points on a component.
- `DamageFlash` – mixin flashing a sprite when taking damage.
- `DebugHealthText` – mixin rendering remaining health in debug mode.

## Planned Components

- [NebulaLayer](nebula_layer.md) – noise-generated nebula sprites cached per
  tile with brightness and density settings.
- [GalaxyLayer](galaxy_layer.md) – distant galaxy bitmap with subtle parallax
  and tint controls.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
