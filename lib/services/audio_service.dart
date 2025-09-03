import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../assets.dart';
import '../constants.dart';
import 'storage_service.dart';

/// Wrapper around `flame_audio` providing sound effects with a mute toggle.
class AudioService {
  AudioService._(this._storage, this.muted, this._shootPool);

  /// Asynchronously create the service and load the persisted mute flag.
  ///
  /// The shoot sound is backed by an [AudioPool] so repeated shots reuse
  /// cached players instead of fetching the asset every time. If the pool
  /// cannot be created (e.g. when the audio plugin isn't available in tests),
  /// a fallback is used that plays the clip directly for each shot.
  static Future<AudioService> create(StorageService storage) async {
    final muted = ValueNotifier<bool>(storage.isMuted());
    AudioPool? shootPool;
    if (kIsWeb) {
      try {
        shootPool = await FlameAudio.createPool(
          Assets.shootSfx,
          maxPlayers: 3,
        );
      } catch (_) {
        shootPool = null;
      }
    }
    return AudioService._(storage, muted, shootPool);
  }

  final StorageService _storage;

  /// Whether audio is muted. Exposed as a [ValueNotifier] for UI binding.
  final ValueNotifier<bool> muted;

  /// Pool for the rapidly-fired shoot sound effect. May be null in tests where
  /// the audio plugin is unavailable.
  final AudioPool? _shootPool;

  /// Toggles the mute flag and persists the new value.
  Future<void> toggleMute() async {
    muted.value = !muted.value;
    if (muted.value) {
      _miningLoop?.stop();
      _miningLoop = null;
    }
    await _storage.setMuted(muted.value);
  }

  /// Plays the shoot sound effect if not muted.
  void playShoot() {
    if (muted.value) return;
    if (_shootPool != null) {
      _shootPool.start();
    } else {
      FlameAudio.play(Assets.shootSfx);
    }
  }

  /// Plays the explosion sound effect if not muted.
  void playExplosion() {
    if (muted.value) return;
    FlameAudio.play(Assets.explosionSfx);
  }

  AudioPlayer? _miningLoop;

  /// Starts the looping mining laser sound if not muted.
  Future<void> startMiningLaser() async {
    if (muted.value || _miningLoop != null) return;
    _miningLoop = await FlameAudio.loop(
      Assets.miningLaserSfx,
      volume: Constants.miningLaserVolume,
    );
  }

  /// Stops the looping mining laser sound if playing.
  void stopMiningLaser() {
    _miningLoop?.stop();
    _miningLoop = null;
  }

  /// Stops all ongoing audio loops.
  void stopAll() {
    stopMiningLaser();
  }
}
