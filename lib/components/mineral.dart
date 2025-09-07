import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';
import '../util/collision_utils.dart';
import 'spawn_remove_emitter.dart';

/// Collectible mineral dropped by destroyed asteroids.
///
/// Instances are pooled by [SpaceGame] to avoid repeated allocations. Call
/// [reset] before adding to the game to set its position and value.
class MineralComponent extends SpriteComponent
    with
        HasGameReference<SpaceGame>,
        CollisionCallbacks,
        SolidBody,
        SpawnRemoveEmitter<MineralComponent> {
  MineralComponent()
      : super(
          size: Vector2.all(
            Constants.mineralSize *
                (Constants.spriteScale + Constants.mineralScale),
          ),
          anchor: Anchor.center,
        );

  /// Amount of minerals granted when collected.
  int value = Constants.asteroidMinerals;

  /// Prepares the mineral for reuse at [position] with optional [value].
  void reset(Vector2 position, {int? value}) {
    this.position..setFrom(position);
    this.value = value ?? Constants.asteroidMinerals;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(Assets.mineralIcon);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    final playerPos = game.targetingService.playerPosition;
    if (playerPos == null) {
      return;
    }
    final toPlayer = playerPos - position;
    final distanceSquared = toPlayer.length2;
    final range = game.upgradeService.tractorRange;
    final rangeSquared = range * range;
    if (distanceSquared == 0 || distanceSquared > rangeSquared) {
      return;
    }
    final distance = math.sqrt(distanceSquared);
    position += toPlayer / distance * Constants.tractorAuraPullSpeed * dt;
  }
}
