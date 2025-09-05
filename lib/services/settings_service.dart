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
        themeMode = ValueNotifier<ThemeMode>(ThemeMode.values[
            storage?.getInt(_themeModeKey, ThemeMode.system.index) ??
                ThemeMode.system.index]),
        muteOnPause = ValueNotifier<bool>(
            storage?.getBool(_muteOnPauseKey, true) ?? true),
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
    themeMode.addListener(
        () => _storage?.setInt(_themeModeKey, themeMode.value.index));
    muteOnPause.addListener(
        () => _storage?.setBool(_muteOnPauseKey, muteOnPause.value));
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

  /// Multiplier applied to HUD buttons and icons.
  final ValueNotifier<double> hudButtonScale;

  /// Multiplier applied to in-game text sizes.
  final ValueNotifier<double> textScale;

  /// Multiplier applied to on-screen joystick elements.
  final ValueNotifier<double> joystickScale;

  /// Currently selected theme mode.
  final ValueNotifier<ThemeMode> themeMode;

  /// Whether audio should fully mute when the game is paused.
  final ValueNotifier<bool> muteOnPause;

  /// Distance used to auto-aim enemies when stationary.
  final ValueNotifier<double> targetingRange;

  /// Radius of the player's Tractor Aura in pixels.
  final ValueNotifier<double> tractorRange;

  /// Maximum distance to auto-mine asteroids, in pixels.
  final ValueNotifier<double> miningRange;

  final StorageService? _storage;

  static const _hudScaleKey = 'hudButtonScale';
  static const _textScaleKey = 'textScale';
  static const _joystickScaleKey = 'joystickScale';
  static const _themeModeKey = 'themeMode';
  static const _muteOnPauseKey = 'muteOnPause';
  static const _targetingRangeKey = 'targetingRange';
  static const _tractorRangeKey = 'tractorRange';
  static const _miningRangeKey = 'miningRange';
}
