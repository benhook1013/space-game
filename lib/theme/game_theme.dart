import 'package:flutter/material.dart';

/// Defines custom colours used throughout the game.
@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({required this.playerLaser, required this.enemyLaser});

  /// Colour for the player's mining laser and related effects.
  final Color playerLaser;

  /// Colour for enemy projectiles.
  final Color enemyLaser;

  @override
  GameColors copyWith({Color? playerLaser, Color? enemyLaser}) {
    return GameColors(
      playerLaser: playerLaser ?? this.playerLaser,
      enemyLaser: enemyLaser ?? this.enemyLaser,
    );
  }

  @override
  GameColors lerp(ThemeExtension<GameColors>? other, double t) {
    if (other is! GameColors) return this;
    return GameColors(
      playerLaser: Color.lerp(playerLaser, other.playerLaser, t)!,
      enemyLaser: Color.lerp(enemyLaser, other.enemyLaser, t)!,
    );
  }

  /// Default colour values.
  static const GameColors dark = GameColors(
    playerLaser: Color(0xffffffff),
    enemyLaser: Color(0xffff8888),
  );
}
