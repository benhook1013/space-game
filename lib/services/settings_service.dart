import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'storage_service.dart';

/// Holds tweakable UI scale values and gameplay ranges for live prototyping.
class SettingsService {
  SettingsService({StorageService? storage}) : _storage = storage {
    hudButtonScale = _initNotifier(_hudScaleKey, defaultHudButtonScale);
    textScale = _initNotifier(_textScaleKey, defaultTextScale);
    joystickScale = _initNotifier(_joystickScaleKey, defaultJoystickScale);
    minimapScale = _initNotifier(_minimapScaleKey, defaultMinimapScale);
    targetingRange =
        _initNotifier(_targetingRangeKey, Constants.playerAutoAimRange);
    tractorRange =
        _initNotifier(_tractorRangeKey, Constants.playerTractorAuraRadius);
    miningRange = _initNotifier(_miningRangeKey, Constants.playerMiningRange);
  }

  static const double defaultHudButtonScale = 0.75;
  static const double defaultTextScale = 1.5;
  static const double defaultJoystickScale = 1;
  static const double defaultMinimapScale = 1;

  /// Multiplier applied to HUD buttons and icons.
  late final ValueNotifier<double> hudButtonScale;

  /// Multiplier applied to in-game text sizes.
  late final ValueNotifier<double> textScale;

  /// Multiplier applied to on-screen joystick elements.
  late final ValueNotifier<double> joystickScale;

  /// Multiplier applied to the minimap size.
  late final ValueNotifier<double> minimapScale;

  /// Distance used to auto-aim enemies when stationary.
  late final ValueNotifier<double> targetingRange;

  /// Radius of the player's Tractor Aura in pixels.
  late final ValueNotifier<double> tractorRange;

  /// Maximum distance to auto-mine asteroids, in pixels.
  late final ValueNotifier<double> miningRange;

  StorageService? _storage;

  /// Attaches a [StorageService] after construction and loads any persisted
  /// values into the existing notifiers. If storage has already been provided,
  /// this call is ignored.
  void attachStorage(StorageService storage) {
    if (_storage != null) {
      return;
    }
    _storage = storage;
    hudButtonScale.value =
        storage.getDouble(_hudScaleKey, hudButtonScale.value);
    textScale.value = storage.getDouble(_textScaleKey, textScale.value);
    joystickScale.value =
        storage.getDouble(_joystickScaleKey, joystickScale.value);
    minimapScale.value =
        storage.getDouble(_minimapScaleKey, minimapScale.value);
    targetingRange.value =
        storage.getDouble(_targetingRangeKey, targetingRange.value);
    tractorRange.value =
        storage.getDouble(_tractorRangeKey, tractorRange.value);
    miningRange.value = storage.getDouble(_miningRangeKey, miningRange.value);
  }

  /// Restores all values to their defaults.
  void reset() {
    hudButtonScale.value = defaultHudButtonScale;
    textScale.value = defaultTextScale;
    joystickScale.value = defaultJoystickScale;
    minimapScale.value = defaultMinimapScale;
    targetingRange.value = Constants.playerAutoAimRange;
    tractorRange.value = Constants.playerTractorAuraRadius;
    miningRange.value = Constants.playerMiningRange;
  }

  static const _hudScaleKey = 'hudButtonScale';
  static const _textScaleKey = 'textScale';
  static const _joystickScaleKey = 'joystickScale';
  static const _minimapScaleKey = 'minimapScale';
  static const _targetingRangeKey = 'targetingRange';
  static const _tractorRangeKey = 'tractorRange';
  static const _miningRangeKey = 'miningRange';

  ValueNotifier<double> _initNotifier(String key, double defaultValue) {
    final notifier = ValueNotifier<double>(
        _storage?.getDouble(key, defaultValue) ?? defaultValue);
    notifier.addListener(() => _storage?.setDouble(key, notifier.value));
    return notifier;
  }

  /// Releases resources held by the service.
  void dispose() {
    hudButtonScale.dispose();
    textScale.dispose();
    joystickScale.dispose();
    minimapScale.dispose();
    targetingRange.dispose();
    tractorRange.dispose();
    miningRange.dispose();
  }
}
