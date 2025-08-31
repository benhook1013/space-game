import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/event_bus.dart';
import '../game/space_game.dart';
import '../util/collision_utils.dart';

/// Collectible mineral dropped by destroyed asteroids.
///
/// Instances are pooled by [SpaceGame] to avoid repeated allocations. Call
/// [reset] before adding to the game to set its position and value.
class MineralComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks, SolidBody {
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
  void onMount() {
    super.onMount();
    game.eventBus.emit(ComponentSpawnEvent<MineralComponent>(this));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final toPlayer = game.player.position - position;
    final distanceSquared = toPlayer.length2;
    final rangeSquared =
        Constants.playerMagnetRange * Constants.playerMagnetRange;
    if (distanceSquared == 0 || distanceSquared > rangeSquared) {
      return;
    }
    final distance = math.sqrt(distanceSquared);
    position += toPlayer / distance * Constants.mineralMagnetSpeed * dt;
  }

  @override
  void onRemove() {
    super.onRemove();
    game.eventBus.emit(ComponentRemoveEvent<MineralComponent>(this));
  }
}
