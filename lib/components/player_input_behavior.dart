import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../game/key_dispatcher.dart';
import '../game/space_game.dart';
import 'bullet.dart';
import 'player.dart';
import '../util/angle_utils.dart';

/// Handles keyboard/joystick input, movement and shooting for the player.
class PlayerInputBehavior extends Component with HasGameReference<SpaceGame> {
  PlayerInputBehavior({
    required this.player,
    required this.joystick,
    required this.keyDispatcher,
  });

  static const _leftKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.arrowLeft,
  ];
  static const _rightKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.arrowRight,
  ];
  static const _upKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.arrowUp,
  ];
  static const _downKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.arrowDown,
  ];

  final PlayerComponent player;
  JoystickComponent joystick;
  final KeyDispatcher keyDispatcher;

  final Vector2 _keyboardDirection = Vector2.zero();
  final Vector2 _input = Vector2.zero();
  double _shootCooldown = 0;
  bool _isShooting = false;

  @override
  void update(double dt) {
    super.update(dt);
    _applyCooldown(dt);
    if (_isShooting) {
      shoot();
    }
    final moved = _processInput(dt);
    if (moved) {
      player.updateRotation(dt);
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
    player.isMoving = false;
    _keyboardDirection
      ..setZero()
      ..x += keyDispatcher.isAnyPressed(_leftKeys) ? -1 : 0
      ..x += keyDispatcher.isAnyPressed(_rightKeys) ? 1 : 0
      ..y += keyDispatcher.isAnyPressed(_upKeys) ? -1 : 0
      ..y += keyDispatcher.isAnyPressed(_downKeys) ? 1 : 0;

    final rawInput =
        joystick.delta.isZero() ? _keyboardDirection : joystick.relativeDelta;
    if (!rawInput.isZero()) {
      _input
        ..setFrom(rawInput)
        ..normalize();
      player.position.addScaled(
        _input,
        game.upgradeService.playerSpeed * dt,
      );
      player.targetAngle = vectorToFlameAngle(_input);
      player.isMoving = true;
      return true;
    }
    return false;
  }

  /// Fires a bullet from the player's current position.
  void shoot() {
    if (!game.stateMachine.isPlaying || _shootCooldown > 0) {
      return;
    }
    final direction = Vector2(
      math.cos(player.angle - math.pi / 2),
      math.sin(player.angle - math.pi / 2),
    );
    final spawnOffset =
        direction * (player.height / 2 + Constants.bulletSize / 2);
    final bullet = game.pools.acquire<BulletComponent>(
      (b) => b.reset(player.position + spawnOffset, direction),
    );
    game.add(bullet);
    game.audioService.playShoot();
    _shootCooldown = game.upgradeService.bulletCooldown;
  }

  /// Begins continuous shooting and fires immediately.
  void startShooting() {
    if (!game.stateMachine.isPlaying) {
      return;
    }
    _isShooting = true;
    shoot();
  }

  /// Stops continuous shooting.
  void stopShooting() {
    _isShooting = false;
  }
}
