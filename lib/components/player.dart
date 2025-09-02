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

/// Controllable player ship.
class PlayerComponent extends SpriteComponent
    with
        HasGameReference<SpaceGame>,
        CollisionCallbacks,
        SpawnRemoveEmitter<PlayerComponent> {
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

  /// Whether to render the auto-aim radius around the player.
  bool showAutoAimRadius = false;

  /// Angle the ship should currently rotate towards.
  double targetAngle = 0;

  /// Whether the player moved during the latest update.
  bool isMoving = false;

  /// Paint used when drawing the auto-aim radius.
  final Paint _autoAimPaint = Paint()
    ..color = const Color(0x66ffffff)
    ..style = PaintingStyle.stroke;

  static final _damageFilter =
      ColorFilter.mode(const Color(0xffff0000), BlendMode.srcATop);

  /// Remaining time for the damage flash effect.
  double _damageFlashTime = 0;

  late final PlayerInputBehavior _input;
  late final AutoAimBehavior _autoAim;

  /// Sets the current sprite for the player.
  void setSprite(String path) {
    _spritePath = path;
    sprite = Sprite(Flame.images.fromCache(_spritePath));
  }

  /// Resets position and orientation to defaults.
  void reset() {
    position = Constants.worldSize / 2;
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

  /// Toggles visibility of the auto-aim radius.
  void toggleAutoAimRadius() {
    showAutoAimRadius = !showAutoAimRadius;
  }

  /// Triggers a short red flash to indicate damage taken.
  void flashDamage() {
    _damageFlashTime = Constants.playerDamageFlashDuration;
    paint.colorFilter = _damageFilter;
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
    _updateDamageFlash(dt);
  }

  void _updateDamageFlash(double dt) {
    if (_damageFlashTime > 0) {
      _damageFlashTime -= dt;
      if (_damageFlashTime <= 0) {
        paint.colorFilter = null;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (showAutoAimRadius) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        Constants.playerAutoAimRange,
        _autoAimPaint,
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
