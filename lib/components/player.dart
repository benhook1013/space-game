import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../game/space_game.dart';
import '../game/key_dispatcher.dart';
import 'asteroid.dart';
import 'enemy.dart';
import '../util/nearest_component.dart';
import 'mineral.dart';

/// Controllable player ship.
class PlayerComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, CollisionCallbacks {
  PlayerComponent(
      {required this.joystick,
      required this.keyDispatcher,
      required String spritePath})
      : _spritePath = spritePath,
        super(
          size: Vector2.all(
            Constants.playerSize * Constants.playerScale,
          ),
          anchor: Anchor.center,
        );

  /// Reference to the on-screen joystick for touch input.
  final JoystickComponent joystick;
  final KeyDispatcher keyDispatcher;

  String _spritePath;

  /// Direction from keyboard input.
  final Vector2 _keyboardDirection = Vector2.zero();

  /// Remaining cooldown time before another shot can fire.
  double _shootCooldown = 0;

  /// Angle the ship should currently rotate towards.
  double _targetAngle = 0;

  /// Whether to render the auto-aim radius around the player.
  bool showAutoAimRadius = false;

  /// Paint used when drawing the auto-aim radius.
  final Paint _autoAimPaint = Paint()
    ..color = const Color(0x66ffffff)
    ..style = PaintingStyle.stroke;

  static const Color _normalColor = Color(0xffffffff);
  static const Color _damageColor = Color(0xffff0000);

  /// Remaining time for the damage flash effect.
  double _damageFlashTime = 0;

  /// Sets the current sprite for the player.
  void setSprite(String path) {
    _spritePath = path;
    sprite = Sprite(Flame.images.fromCache(_spritePath));
  }

  /// Resets the player to its default orientation and clears input state.
  void reset() {
    position = Constants.worldSize / 2;
    angle = 0;
    _targetAngle = 0;
    _shootCooldown = 0;
    _keyboardDirection.setZero();
  }

  /// Toggles visibility of the auto-aim radius.
  void toggleAutoAimRadius() {
    showAutoAimRadius = !showAutoAimRadius;
  }

  /// Triggers a short red flash to indicate damage taken.
  void flashDamage() {
    _damageFlashTime = Constants.playerDamageFlashDuration;
    paint.color = _damageColor;
  }

  /// Fires a bullet from the player's current position.
  void shoot() {
    if (_shootCooldown > 0) {
      return;
    }
    final direction =
        Vector2(math.cos(angle - math.pi / 2), math.sin(angle - math.pi / 2));
    final bullet = game.acquireBullet(position.clone(), direction);
    game.add(bullet);
    game.audioService.playShoot();
    _shootCooldown = Constants.bulletCooldown;
  }

  @override
  Future<void> onLoad() async {
    setSprite(_spritePath);
    paint.color = _normalColor;
    add(CircleHitbox());
    keyDispatcher.register(LogicalKeyboardKey.space, onDown: shoot);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_damageFlashTime > 0) {
      _damageFlashTime -= dt;
      if (_damageFlashTime <= 0) {
        paint.color = _normalColor;
      }
    }
    _keyboardDirection
      ..setZero()
      ..x += keyDispatcher.isAnyPressed([
        LogicalKeyboardKey.keyA,
        LogicalKeyboardKey.arrowLeft,
      ])
          ? -1
          : 0
      ..x += keyDispatcher.isAnyPressed([
        LogicalKeyboardKey.keyD,
        LogicalKeyboardKey.arrowRight,
      ])
          ? 1
          : 0
      ..y += keyDispatcher.isAnyPressed([
        LogicalKeyboardKey.keyW,
        LogicalKeyboardKey.arrowUp,
      ])
          ? -1
          : 0
      ..y += keyDispatcher.isAnyPressed([
        LogicalKeyboardKey.keyS,
        LogicalKeyboardKey.arrowDown,
      ])
          ? 1
          : 0;

    if (_shootCooldown > 0) {
      _shootCooldown -= dt;
    }
    var input =
        joystick.delta.isZero() ? _keyboardDirection : joystick.relativeDelta;
    if (!input.isZero()) {
      input = input.normalized();
      position += input * Constants.playerSpeed * dt;
      final halfSize = Vector2.all(size.x / 2);
      position.clamp(
        halfSize,
        Constants.worldSize - halfSize,
      );
      _targetAngle = math.atan2(input.y, input.x) + math.pi / 2;
    } else {
      _autoAimTimer += dt;
      if (_autoAimTimer >= Constants.playerAutoAimInterval) {
        _autoAimTimer = 0;
        final enemies = game.enemies.isNotEmpty
            ? game.enemies
            : game.children.whereType<EnemyComponent>();
        final target = enemies.findClosest(
          position,
          Constants.playerAutoAimRange,
        );
        if (target != null) {
          _targetAngle = math.atan2(
                target.position.y - position.y,
                target.position.x - position.x,
              ) +
              math.pi / 2;
        }
      }
    }
    final rotationDelta = _normalizeAngle(_targetAngle - angle);
    final maxDelta = Constants.playerRotationSpeed * dt;
    if (rotationDelta.abs() <= maxDelta) {
      angle = _targetAngle;
    } else {
      angle += maxDelta * rotationDelta.sign;
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
