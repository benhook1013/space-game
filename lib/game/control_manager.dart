import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/material.dart' show ColorScheme;

import '../components/player.dart';
import '../services/settings_service.dart';

/// Manages on-screen controls like the joystick and fire button.
///
/// Listens for [SettingsService.joystickScale] updates to resize controls
/// without recreating them.
class ControlManager {
  ControlManager({
    required this.game,
    required this.settings,
    required this.colorScheme,
  });

  static const double _joystickKnobRadius = 20;
  static const double _joystickBackgroundRadius = 50;
  static const double _fireButtonRadius = 30;
  static const double _controlMargin = 40;

  /// Host game used to mount control components.
  final FlameGame game;

  /// Provides runtime-adjustable control scale.
  final SettingsService settings;

  /// Colours used to style the joystick and fire button.
  final ColorScheme colorScheme;

  late JoystickComponent _joystick;
  JoystickComponent get joystick => _joystick;
  set joystick(JoystickComponent value) => _joystick = value;

  HudButtonComponent? fireButton;

  /// Builds and adds the joystick to the game.
  Future<void> init() async {
    _joystick = _buildJoystick();
    await game.add(_joystick);
    settings.joystickScale.addListener(_updateJoystickScale);
  }

  /// Builds and adds the fire button once the [player] is ready.
  Future<void> attachPlayer(PlayerComponent player) async {
    fireButton = _buildFireButton(settings.joystickScale.value, player);
    await game.add(fireButton!);
  }

  JoystickComponent _buildJoystick() {
    final scale = settings.joystickScale.value;
    final scheme = colorScheme;
    return JoystickComponent(
      knob: CircleComponent(
        radius: _joystickKnobRadius * scale,
        paint: Paint()..color = scheme.primary,
      ),
      background: CircleComponent(
        radius: _joystickBackgroundRadius * scale,
        paint: Paint()..color = scheme.primary.withValues(alpha: 0.4),
      ),
      margin: const EdgeInsets.only(
        left: _controlMargin,
        bottom: _controlMargin,
      ),
    )..anchor = Anchor.bottomLeft;
  }

  HudButtonComponent _buildFireButton(double scale, PlayerComponent player) {
    final scheme = colorScheme;
    final radius = _fireButtonRadius * scale;
    return HudButtonComponent(
      button: CircleComponent(
        radius: radius,
        paint: Paint()..color = scheme.primary.withValues(alpha: 0.4),
      ),
      buttonDown: CircleComponent(
        radius: radius,
        paint: Paint()..color = scheme.primary,
      ),
      anchor: Anchor.bottomRight,
      margin: const EdgeInsets.only(
        right: _controlMargin,
        bottom: _controlMargin,
      ),
      onPressed: player.startShooting,
      onReleased: player.stopShooting,
      onCancelled: player.stopShooting,
    )..size = Vector2.all(radius * 2);
  }

  void _updateJoystickScale() {
    final scale = settings.joystickScale.value;
    final bg = _joystick.background as CircleComponent;
    final knob = _joystick.knob as CircleComponent;
    bg
      ..radius = _joystickBackgroundRadius * scale
      ..position.setZero();
    knob
      ..radius = _joystickKnobRadius * scale
      ..position.setZero();
    _joystick
      ..size = Vector2.all((_joystickBackgroundRadius * 2) * scale)
      ..knobRadius = _joystickKnobRadius * scale
      ..anchor = Anchor.bottomLeft
      ..position.setValues(
        _controlMargin,
        game.size.y - _controlMargin,
      );
    _joystick.onGameResize(game.size);

    final fb = fireButton;
    if (fb != null) {
      final radius = _fireButtonRadius * scale;
      (fb.button as CircleComponent).radius = radius;
      (fb.buttonDown as CircleComponent).radius = radius;
      fb
        ..size = Vector2.all(radius * 2)
        ..anchor = Anchor.bottomRight;
      fb.onGameResize(game.size);
    }
  }

  /// Cleans up listeners and removes controls from the game.
  void dispose() {
    settings.joystickScale.removeListener(_updateJoystickScale);
    _joystick.removeFromParent();
    fireButton?.removeFromParent();
  }
}
