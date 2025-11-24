import 'dart:async';

import 'package:flutter/foundation.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';
import 'audio_service.dart';

/// Handles non-essential asset loading and pause/resume behaviour.
class AssetLifecycleService {
  AssetLifecycleService({
    required this.game,
    required this.audioService,
  }) {
    _storedVolume = audioService.masterVolume;
    _volumeListener = () {
      if (!_suppressVolumeSave) {
        _storedVolume = audioService.masterVolume;
      }
    };
    audioService.volume.addListener(_volumeListener);
  }

  final SpaceGame game;
  final AudioService audioService;

  late final VoidCallback _volumeListener;

  /// Reports progress while remaining assets load.
  final ValueNotifier<double> assetLoadProgress = ValueNotifier<double>(0);
  Future<void>? _assetLoadFuture;

  double _storedVolume = 1;
  bool _suppressVolumeSave = false;

  /// Begins loading assets needed for gameplay.
  ///
  /// Safe to call multiple times; subsequent invocations are ignored.
  void startLoadingAssets() {
    _assetLoadFuture ??= Assets.loadRemaining(
      onProgress: (p) => assetLoadProgress.value = p,
    );
  }

  Future<void> _ensureAssetsLoaded() async {
    await (_assetLoadFuture ??= Assets.loadRemaining(
      onProgress: (p) => assetLoadProgress.value = p,
    ));
    assetLoadProgress.value = 1;
  }

  /// Starts a new game session once assets have loaded.
  Future<void> startGame() async {
    await _ensureAssetsLoaded();
    _suppressVolumeSave = true;
    audioService.setMasterVolume(_storedVolume);
    _suppressVolumeSave = false;
    game.stateMachine.startGame();
  }

  /// Pauses the game and lowers audio volume.
  void pauseGame() {
    if (!game.stateMachine.isPlaying) {
      return;
    }
    game.stateMachine.pauseGame();
    _storedVolume = audioService.masterVolume;
    _suppressVolumeSave = true;
    audioService.setMasterVolume(
      _storedVolume * Constants.pausedAudioVolumeFactor,
    );
    _suppressVolumeSave = false;
  }

  /// Resumes the game and restores audio volume.
  void resumeGame() {
    if (!game.stateMachine.isPaused) {
      return;
    }
    game.stateMachine.resumeGame();
    game.resumeEngine();
    _suppressVolumeSave = true;
    audioService.setMasterVolume(_storedVolume);
    _suppressVolumeSave = false;
    game.focusGame();
  }

  void dispose() {
    audioService.volume.removeListener(_volumeListener);
    assetLoadProgress.dispose();
  }
}
