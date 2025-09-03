import 'package:flutter/material.dart';

/// Custom colours used throughout the game that are not covered by the core
/// [ColorScheme].
@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({
    required this.miningLaser,
    required this.enemyLaser,
  });

  /// Colour of the player's mining laser beam.
  final Color miningLaser;

  /// Colour of enemy laser projectiles.
  final Color enemyLaser;

  @override
  GameColors copyWith({Color? miningLaser, Color? enemyLaser}) {
    return GameColors(
      miningLaser: miningLaser ?? this.miningLaser,
      enemyLaser: enemyLaser ?? this.enemyLaser,
    );
  }

  @override
  GameColors lerp(ThemeExtension<GameColors>? other, double t) {
    if (other is! GameColors) {
      return this;
    }
    return GameColors(
      miningLaser: Color.lerp(miningLaser, other.miningLaser, t)!,
      enemyLaser: Color.lerp(enemyLaser, other.enemyLaser, t)!,
    );
  }
}
