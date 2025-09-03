import 'package:flutter/foundation.dart';

/// Holds tweakable UI scale values for live prototyping.
class SettingsService {
  SettingsService()
      : hudButtonScale = ValueNotifier<double>(defaultHudButtonScale),
        textScale = ValueNotifier<double>(defaultTextScale),
        joystickScale = ValueNotifier<double>(defaultJoystickScale);

  static const double defaultHudButtonScale = 0.75;
  static const double defaultTextScale = 0.75;
  static const double defaultJoystickScale = 1;

  /// Multiplier applied to HUD buttons and icons.
  final ValueNotifier<double> hudButtonScale;

  /// Multiplier applied to in-game text sizes.
  final ValueNotifier<double> textScale;

  /// Multiplier applied to on-screen joystick elements.
  final ValueNotifier<double> joystickScale;
}
