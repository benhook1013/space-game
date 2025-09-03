import 'package:flutter/foundation.dart';

/// Holds tweakable UI scale values for live prototyping.
class SettingsService {
  SettingsService()
      : hudButtonScale = ValueNotifier<double>(1),
        textScale = ValueNotifier<double>(1),
        joystickScale = ValueNotifier<double>(1);

  /// Multiplier applied to HUD buttons and icons.
  final ValueNotifier<double> hudButtonScale;

  /// Multiplier applied to in-game text sizes.
  final ValueNotifier<double> textScale;

  /// Multiplier applied to on-screen joystick elements.
  final ValueNotifier<double> joystickScale;
}
