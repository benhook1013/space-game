import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../game/space_game.dart';
import 'asteroid.dart';
import 'enemy.dart';

/// Controllable player ship.
class PlayerComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, KeyboardHandler, CollisionCallbacks {
  PlayerComponent({required this.joystick, required String spritePath})
      : _spritePath = spritePath,
        super(
          size: Vector2.all(
            Constants.playerSize * Constants.playerScale,
          ),
          anchor: Anchor.center,
        );

  /// Reference to the on-screen joystick for touch input.
  final JoystickComponent joystick;

  String _spritePath;

  /// Direction from keyboard input.
  final Vector2 _keyboardDirection = Vector2.zero();

  /// Remaining cooldown time before another shot can fire.
  double _shootCooldown = 0;

  /// Angle the ship should currently rotate towards.
  double _targetAngle = 0;

  /// Accumulates time between auto-aim updates when stationary.
  double _autoAimTimer = 0;

  /// Whether to render the auto-aim radius around the player.
  bool showAutoAimRadius = false;

  /// Paint used when drawing the auto-aim radius.
  final Paint _autoAimPaint = Paint()
    ..color = const Color(0x66ffffff)
    ..style = PaintingStyle.stroke;

  /// Sets the current sprite for the player.
  void setSprite(String path) {
    _spritePath = path;
    sprite = Sprite(Flame.images.fromCache(_spritePath));
  }

  /// Resets the player to its default orientation and clears input state.
  void reset() {
    position = game.size / 2;
    angle = 0;
    _targetAngle = 0;
    _shootCooldown = 0;
    _keyboardDirection.setZero();
  }

  /// Toggles visibility of the auto-aim radius.
  void toggleAutoAimRadius() {
    showAutoAimRadius = !showAutoAimRadius;
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
    add(CircleHitbox());
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shootCooldown > 0) {
      _shootCooldown -= dt;
    }
    var input =
        joystick.delta.isZero() ? _keyboardDirection : joystick.relativeDelta;
    if (!input.isZero()) {
      input = input.normalized();
      position += input * Constants.playerSpeed * dt;
      position.clamp(
        Vector2.all(size.x / 2),
        game.size - Vector2.all(size.x / 2),
      );
      _targetAngle = math.atan2(input.y, input.x) + math.pi / 2;
      _autoAimTimer = 0;
    } else {
      _autoAimTimer += dt;
      if (_autoAimTimer >= Constants.playerAutoAimInterval) {
        _autoAimTimer = 0;
        final target = _findClosestEnemy();
        if (target != null) {
          _targetAngle = math.atan2(target.position.y - position.y,
                  target.position.x - position.x) +
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
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      shoot();
    }
    _keyboardDirection
      ..setZero()
      ..x += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
              keysPressed.contains(LogicalKeyboardKey.arrowLeft))
          ? -1
          : 0
      ..x += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
              keysPressed.contains(LogicalKeyboardKey.arrowRight))
          ? 1
          : 0
      ..y += (keysPressed.contains(LogicalKeyboardKey.keyW) ||
              keysPressed.contains(LogicalKeyboardKey.arrowUp))
          ? -1
          : 0
      ..y += (keysPressed.contains(LogicalKeyboardKey.keyS) ||
              keysPressed.contains(LogicalKeyboardKey.arrowDown))
          ? 1
          : 0;
    return true;
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

  EnemyComponent? _findClosestEnemy() {
    EnemyComponent? closest;
    var closestDistance = Constants.playerAutoAimRange;
    Iterable<EnemyComponent> enemies = game.enemies;
    if (enemies.isEmpty) {
      enemies = game.children.whereType<EnemyComponent>();
    }
    for (final enemy in enemies) {
      final distance = enemy.position.distanceTo(position);
      if (distance <= closestDistance) {
        closest = enemy;
        closestDistance = distance;
      }
    }
    return closest;
  }
}
