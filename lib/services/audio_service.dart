import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../assets.dart';
import 'storage_service.dart';

/// Wrapper around `flame_audio` providing sound effects with a mute toggle.
class AudioService {
  AudioService._(this._storage, this.muted);

  /// Asynchronously create the service and load the persisted mute flag.
  static Future<AudioService> create(StorageService storage) async {
    final muted = ValueNotifier<bool>(storage.isMuted());
    return AudioService._(storage, muted);
  }

  final StorageService _storage;

  /// Whether audio is muted. Exposed as a [ValueNotifier] for UI binding.
  final ValueNotifier<bool> muted;

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
    FlameAudio.play(Assets.shootSfx);
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
    _miningLoop = await FlameAudio.loop(Assets.miningLaserSfx);
  }

  /// Stops the looping mining laser sound if playing.
  void stopMiningLaser() {
    _miningLoop?.stop();
    _miningLoop = null;
  }
}
