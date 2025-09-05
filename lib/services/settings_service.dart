import 'package:flutter/material.dart';

import '../constants.dart';

/// Holds tweakable UI scale values and gameplay ranges for live prototyping.
class SettingsService {
  SettingsService()
      : hudButtonScale = ValueNotifier<double>(defaultHudButtonScale),
        textScale = ValueNotifier<double>(defaultTextScale),
        joystickScale = ValueNotifier<double>(defaultJoystickScale),
        themeMode = ValueNotifier<ThemeMode>(ThemeMode.system),
        targetingRange = ValueNotifier<double>(Constants.playerAutoAimRange),
        tractorRange = ValueNotifier<double>(Constants.playerTractorAuraRadius),
        miningRange = ValueNotifier<double>(Constants.playerMiningRange);

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

  /// Distance used to auto-aim enemies when stationary.
  final ValueNotifier<double> targetingRange;

  /// Radius of the player's Tractor Aura in pixels.
  final ValueNotifier<double> tractorRange;

  /// Maximum distance to auto-mine asteroids, in pixels.
  final ValueNotifier<double> miningRange;
}
