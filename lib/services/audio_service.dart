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
    await _storage.setMuted(muted.value);
  }

  /// Plays the shoot sound effect if not muted.
  void playShoot() {
    if (muted.value) return;
    FlameAudio.play(Assets.shootSfx);
  }
}
