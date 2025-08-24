import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';
import 'asteroid.dart';
import 'enemy.dart';

/// Controllable player ship.
class PlayerComponent extends SpriteComponent
    with HasGameReference<SpaceGame>, KeyboardHandler, CollisionCallbacks {
  PlayerComponent({required this.joystick})
    : super(size: Vector2.all(Constants.playerSize), anchor: Anchor.center);

  /// Reference to the on-screen joystick for touch input.
  final JoystickComponent joystick;

  /// Direction from keyboard input.
  final Vector2 _keyboardDirection = Vector2.zero();

  /// Fires a bullet from the player's current position.
  void shoot() {
    final bullet = game.acquireBullet(position.clone(), Vector2(0, -1));
    game.add(bullet);
    game.audioService.playShoot();
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(Assets.player);
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
    var input = joystick.delta.isZero()
        ? _keyboardDirection
        : joystick.relativeDelta;
    if (!input.isZero()) {
      input = input.normalized();
      position += input * Constants.playerSpeed * dt;
      position.clamp(
        Vector2.all(size.x / 2),
        game.size - Vector2.all(size.x / 2),
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
      ..x +=
          (keysPressed.contains(LogicalKeyboardKey.keyA) ||
              keysPressed.contains(LogicalKeyboardKey.arrowLeft))
          ? -1
          : 0
      ..x +=
          (keysPressed.contains(LogicalKeyboardKey.keyD) ||
              keysPressed.contains(LogicalKeyboardKey.arrowRight))
          ? 1
          : 0
      ..y +=
          (keysPressed.contains(LogicalKeyboardKey.keyW) ||
              keysPressed.contains(LogicalKeyboardKey.arrowUp))
          ? -1
          : 0
      ..y +=
          (keysPressed.contains(LogicalKeyboardKey.keyS) ||
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
      game.gameOver();
    }
  }
}
