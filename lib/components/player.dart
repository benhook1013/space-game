import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../game/key_dispatcher.dart';
import '../game/space_game.dart';
import 'asteroid.dart';
import 'auto_aim_behavior.dart';
import 'enemy.dart';
import 'mineral.dart';
import 'player_input_behavior.dart';
import 'spawn_remove_emitter.dart';
import 'tractor_aura_renderer.dart';
import 'damage_flash.dart';

/// Controllable player ship.
class PlayerComponent extends SpriteComponent
    with
        HasGameReference<SpaceGame>,
        CollisionCallbacks,
        SpawnRemoveEmitter<PlayerComponent>,
        DamageFlash {
  PlayerComponent({
    required this.joystick,
    required this.keyDispatcher,
    required String spritePath,
  })  : _spritePath = spritePath,
        super(
          size: Vector2.all(
            Constants.playerSize *
                (Constants.spriteScale + Constants.playerScale),
          ),
          anchor: Anchor.center,
        ) {
    _input = PlayerInputBehavior(
      player: this,
      joystick: joystick,
      keyDispatcher: keyDispatcher,
    );
  }

  /// Reference to the on-screen joystick for touch input.
  JoystickComponent joystick;
  final KeyDispatcher keyDispatcher;

  String _spritePath;

  /// Whether to render targeting, tractor and mining range rings.
  bool showRangeRings = false;

  /// Angle the ship should currently rotate towards.
  double targetAngle = 0;

  /// Whether the player moved during the latest update.
  bool isMoving = false;

  /// Paint used when drawing the targeting range.
  final Paint _targetingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0x66ff0000);

  /// Paint used when drawing the Tractor Aura range.
  final Paint _tractorPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0x660000ff);

  /// Paint used when drawing the mining laser range.
  final Paint _miningPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0x66ffff00);

  late final PlayerInputBehavior _input;
  late final AutoAimBehavior _autoAim;

  /// Sets the current sprite for the player.
  void setSprite(String path) {
    _spritePath = path;
    sprite = Sprite(Flame.images.fromCache(_spritePath));
  }

  /// Resets position and orientation to defaults.
  void reset() {
    position.setZero();
    angle = 0;
    targetAngle = 0;
  }

  /// Clears any lingering input state.
  void resetInput() {
    _input.reset();
  }

  /// Exposes the input behavior for testing.
  PlayerInputBehavior get inputBehavior => _input;

  /// Updates the joystick reference and underlying input behavior.
  void setJoystick(JoystickComponent joystick) {
    this.joystick = joystick;
    _input.joystick = joystick;
  }

  /// Toggles visibility of the player's range rings.
  void toggleRangeRings() {
    showRangeRings = !showRangeRings;
  }

  /// Allows external callers to fire a bullet.
  void shoot() => _input.shoot();

  /// Begins continuous shooting.
  void startShooting() => _input.startShooting();

  /// Stops continuous shooting.
  void stopShooting() => _input.stopShooting();

  @override
  Future<void> onLoad() async {
    setSprite(_spritePath);
    paint.color = const Color(0xffffffff);
    paint.colorFilter = null;
    add(CircleHitbox());
    _autoAim = AutoAimBehavior();
    await add(_input);
    await add(_autoAim);
    await add(TractorAuraRenderer());
  }

  @override
  void onMount() {
    super.onMount();
    if (!contains(_input)) {
      add(_input);
    }
    if (!contains(_autoAim)) {
      add(_autoAim);
    }
    keyDispatcher.register(
      LogicalKeyboardKey.space,
      onDown: startShooting,
      onUp: stopShooting,
    );
  }

  @override
  void onRemove() {
    keyDispatcher.unregister(LogicalKeyboardKey.space);
    super.onRemove();
  }

  /// Smoothly rotates the player toward [targetAngle].
  void updateRotation(double dt) {
    final rotationDelta = _normalizeAngle(targetAngle - angle);
    final maxDelta = Constants.playerRotationSpeed * dt;
    if (rotationDelta.abs() <= maxDelta) {
      angle = targetAngle;
    } else {
      angle += maxDelta * rotationDelta.sign;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (showRangeRings) {
      final center = Offset(size.x / 2, size.y / 2);
      canvas.drawCircle(
        center,
        game.upgradeService.targetingRange,
        _targetingPaint,
      );
      canvas.drawCircle(
        center,
        game.upgradeService.tractorRange,
        _tractorPaint,
      );
      canvas.drawCircle(
        center,
        game.settingsService.miningRange.value,
        _miningPaint,
      );
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyComponent || other is AsteroidComponent) {
      other.removeFromParent();
      game.hitPlayer();
    } else if (other is MineralComponent) {
      game.addMinerals(other.value);
      other.removeFromParent();
    }
  }

  double _normalizeAngle(double a) {
    while (a <= -math.pi) {
      a += math.pi * 2;
    }
    while (a > math.pi) {
      a -= math.pi * 2;
    }
    return a;
  }
}
