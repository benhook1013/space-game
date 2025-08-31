import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../constants.dart';
import '../game/space_game.dart';
import 'asteroid.dart';
import 'player.dart';
import '../util/nearest_component.dart';

/// Automatically mines the nearest asteroid within range.
class MiningLaserComponent extends Component with HasGameReference<SpaceGame> {
  MiningLaserComponent({required this.player}) {
    _pulseTimer.onTick = () {
      _paint.strokeWidth = 2;
      _target?.takeDamage(Constants.miningPulseDamage);
      if (_target?.isMounted != true) {
        _target = null;
      }
    };
  }

  final PlayerComponent player;
  AsteroidComponent? _target;
  final Paint _paint = Paint()..color = const Color(0x66ffffff);
  final Timer _pulseTimer = Timer(Constants.miningPulseInterval, repeat: true);
  bool _playingSound = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (!player.isMounted) return;

    final rangeSquared =
        Constants.playerMiningRange * Constants.playerMiningRange;
    if (_target == null ||
        !_target!.isMounted ||
        _target!.position.distanceToSquared(player.position) > rangeSquared) {
      final asteroids = game.pools.nearbyAsteroids(
        player.position,
        Constants.playerMiningRange,
      );
      _target = asteroids.findClosest(
        player.position,
        Constants.playerMiningRange,
      );
      _pulseTimer
        ..stop()
        ..start();
    }

    if (_target != null) {
      _pulseTimer.update(dt);
      final progress = _pulseTimer.progress;
      _paint.strokeWidth = 2 + 2 * progress;
      if (!_playingSound) {
        unawaited(game.audioService.startMiningLaser());
        _playingSound = true;
      }
    } else {
      _pulseTimer.stop();
      _paint.strokeWidth = 2;
      if (_playingSound) {
        game.audioService.stopMiningLaser();
        _playingSound = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_target == null || !_target!.isMounted) return;
    canvas.drawLine(
      player.position.toOffset(),
      _target!.position.toOffset(),
      _paint,
    );
  }
}
