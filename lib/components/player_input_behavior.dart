import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../game/key_dispatcher.dart';
import '../game/space_game.dart';
import 'bullet.dart';
import 'player.dart';

/// Handles keyboard/joystick input, movement and shooting for the player.
class PlayerInputBehavior extends Component
    with HasGameReference<SpaceGame>, ParentIsA<PlayerComponent> {
  PlayerInputBehavior({
    required this.joystick,
    required this.keyDispatcher,
  });

  final JoystickComponent joystick;
  final KeyDispatcher keyDispatcher;

  final Vector2 _keyboardDirection = Vector2.zero();
  double _shootCooldown = 0;
  bool _isShooting = false;

  @override
  void onMount() {
    super.onMount();
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

  @override
  void update(double dt) {
    super.update(dt);
    _applyCooldown(dt);
    if (_isShooting) {
      shoot();
    }
    final moved = _processInput(dt);
    if (moved) {
      parent.updateRotation(dt);
    }
  }

  /// Clears movement and shooting state for a fresh start.
  void reset() {
    _shootCooldown = 0;
    _keyboardDirection.setZero();
    _isShooting = false;
  }

  void _applyCooldown(double dt) {
    if (_shootCooldown > 0) {
      _shootCooldown -= dt;
    }
  }

  bool _processInput(double dt) {
    parent.isMoving = false;
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

    var input =
        joystick.delta.isZero() ? _keyboardDirection : joystick.relativeDelta;
    if (!input.isZero()) {
      input = input.normalized();
      parent.position += input * Constants.playerSpeed * dt;
      final halfSize = Vector2.all(parent.size.x / 2);
      parent.position.clamp(
        halfSize,
        Constants.worldSize - halfSize,
      );
      parent.targetAngle = math.atan2(input.y, input.x) + math.pi / 2;
      parent.isMoving = true;
      return true;
    }
    return false;
  }

  /// Fires a bullet from the player's current position.
  void shoot() {
    if (_shootCooldown > 0) {
      return;
    }
    final direction = Vector2(
      math.cos(parent.angle - math.pi / 2),
      math.sin(parent.angle - math.pi / 2),
    );
    final bullet = game.pools.acquire<BulletComponent>(
      (b) => b.reset(parent.position.clone(), direction),
    );
    game.add(bullet);
    game.audioService.playShoot();
    _shootCooldown = Constants.bulletCooldown;
  }

  /// Begins continuous shooting and fires immediately.
  void startShooting() {
    _isShooting = true;
    shoot();
  }

  /// Stops continuous shooting.
  void stopShooting() {
    _isShooting = false;
  }
}
