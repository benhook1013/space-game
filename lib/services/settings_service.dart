import 'package:flutter/material.dart';

import '../constants.dart';
import 'storage_service.dart';

/// Holds tweakable UI scale values and gameplay ranges for live prototyping.
class SettingsService {
  SettingsService({StorageService? storage})
      : _storage = storage,
        hudButtonScale = ValueNotifier<double>(
            storage?.getDouble(_hudScaleKey, defaultHudButtonScale) ??
                defaultHudButtonScale),
        textScale = ValueNotifier<double>(
            storage?.getDouble(_textScaleKey, defaultTextScale) ??
                defaultTextScale),
        joystickScale = ValueNotifier<double>(
            storage?.getDouble(_joystickScaleKey, defaultJoystickScale) ??
                defaultJoystickScale),
        minimapScale = ValueNotifier<double>(
            storage?.getDouble(_minimapScaleKey, defaultMinimapScale) ??
                defaultMinimapScale),
        themeMode = ValueNotifier<ThemeMode>(ThemeMode.values[
            storage?.getInt(_themeModeKey, ThemeMode.system.index) ??
                ThemeMode.system.index]),
        targetingRange = ValueNotifier<double>(storage?.getDouble(
                _targetingRangeKey, Constants.playerAutoAimRange) ??
            Constants.playerAutoAimRange),
        tractorRange = ValueNotifier<double>(storage?.getDouble(
                _tractorRangeKey, Constants.playerTractorAuraRadius) ??
            Constants.playerTractorAuraRadius),
        miningRange = ValueNotifier<double>(
            storage?.getDouble(_miningRangeKey, Constants.playerMiningRange) ??
                Constants.playerMiningRange) {
    hudButtonScale.addListener(
        () => _storage?.setDouble(_hudScaleKey, hudButtonScale.value));
    textScale
        .addListener(() => _storage?.setDouble(_textScaleKey, textScale.value));
    joystickScale.addListener(
        () => _storage?.setDouble(_joystickScaleKey, joystickScale.value));
    minimapScale.addListener(
        () => _storage?.setDouble(_minimapScaleKey, minimapScale.value));
    themeMode.addListener(
        () => _storage?.setInt(_themeModeKey, themeMode.value.index));
    targetingRange.addListener(
        () => _storage?.setDouble(_targetingRangeKey, targetingRange.value));
    tractorRange.addListener(
        () => _storage?.setDouble(_tractorRangeKey, tractorRange.value));
    miningRange.addListener(
        () => _storage?.setDouble(_miningRangeKey, miningRange.value));
  }

  static const double defaultHudButtonScale = 0.75;
  static const double defaultTextScale = 1.5;
  static const double defaultJoystickScale = 1;
  static const double defaultMinimapScale = 1;

  /// Multiplier applied to HUD buttons and icons.
  final ValueNotifier<double> hudButtonScale;

  /// Multiplier applied to in-game text sizes.
  final ValueNotifier<double> textScale;

  /// Multiplier applied to on-screen joystick elements.
  final ValueNotifier<double> joystickScale;

  /// Multiplier applied to the minimap size.
  final ValueNotifier<double> minimapScale;

  /// Currently selected theme mode.
  final ValueNotifier<ThemeMode> themeMode;

  /// Distance used to auto-aim enemies when stationary.
  final ValueNotifier<double> targetingRange;

  /// Radius of the player's Tractor Aura in pixels.
  final ValueNotifier<double> tractorRange;

  /// Maximum distance to auto-mine asteroids, in pixels.
  final ValueNotifier<double> miningRange;

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
    themeMode.value =
        ThemeMode.values[storage.getInt(_themeModeKey, themeMode.value.index)];
    targetingRange.value =
        storage.getDouble(_targetingRangeKey, targetingRange.value);
    tractorRange.value =
        storage.getDouble(_tractorRangeKey, tractorRange.value);
    miningRange.value = storage.getDouble(_miningRangeKey, miningRange.value);
  }

  static const _hudScaleKey = 'hudButtonScale';
  static const _textScaleKey = 'textScale';
  static const _joystickScaleKey = 'joystickScale';
  static const _minimapScaleKey = 'minimapScale';
  static const _themeModeKey = 'themeMode';
  static const _targetingRangeKey = 'targetingRange';
  static const _tractorRangeKey = 'tractorRange';
  static const _miningRangeKey = 'miningRange';
}
