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
    };
  }

  final PlayerComponent player;
  AsteroidComponent? _target;
  final Paint _paint = Paint();
  late void Function() _colorListener;
  final Timer _pulseTimer = Timer(Constants.miningPulseInterval, repeat: true);
  bool _playingSound = false;

  @override
  void onMount() {
    super.onMount();
    void updateColor() {
      _paint.color = game.gameColors.value.playerLaser.withValues(alpha: 0.4);
    }

    updateColor();
    _colorListener = updateColor;
    game.gameColors.addListener(_colorListener);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!player.isMounted) {
      _target = null;
      _pulseTimer.stop();
      _paint.strokeWidth = 2;
      if (_playingSound) {
        game.audioService.stopMiningLaser();
        _playingSound = false;
      }
      return;
    }

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
      if (_target?.isMounted != true || _target?.isRemoving == true) {
        // Target was destroyed or removed; cancel the audio loop immediately
        // instead of waiting for the next frame.
        _target = null;
        _pulseTimer.stop();
        _paint.strokeWidth = 2;
        if (_playingSound) {
          game.audioService.stopMiningLaser();
          _playingSound = false;
        }
      } else {
        final progress = _pulseTimer.progress;
        _paint.strokeWidth = 2 + 2 * progress;
        if (!_playingSound) {
          unawaited(game.audioService.startMiningLaser());
          _playingSound = true;
        }
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

  @override
  void onRemove() {
    if (_playingSound) {
      game.audioService.stopMiningLaser();
      _playingSound = false;
    }
    game.gameColors.removeListener(_colorListener);
    super.onRemove();
  }
}
