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
        radius: 20 * scale,
        paint: Paint()..color = scheme.primary,
      ),
      background: CircleComponent(
        radius: 50 * scale,
        paint: Paint()..color = scheme.primary.withValues(alpha: 0.4),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    )..anchor = Anchor.bottomLeft;
  }

  HudButtonComponent _buildFireButton(double scale, PlayerComponent player) {
    final scheme = colorScheme;
    return HudButtonComponent(
      button: CircleComponent(
        radius: 30 * scale,
        paint: Paint()..color = scheme.primary.withValues(alpha: 0.4),
      ),
      buttonDown: CircleComponent(
        radius: 30 * scale,
        paint: Paint()..color = scheme.primary,
      ),
      anchor: Anchor.bottomRight,
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: player.startShooting,
      onReleased: player.stopShooting,
      onCancelled: player.stopShooting,
    )..size = Vector2.all(60 * scale);
  }

  void _updateJoystickScale() {
    final scale = settings.joystickScale.value;
    final bg = _joystick.background as CircleComponent;
    final knob = _joystick.knob as CircleComponent;
    bg
      ..radius = 50 * scale
      ..position = Vector2.zero();
    knob
      ..radius = 20 * scale
      ..position = Vector2.zero();
    _joystick
      ..size = Vector2.all(100 * scale)
      ..knobRadius = 20 * scale
      ..anchor = Anchor.bottomLeft
      ..position = Vector2(40, game.size.y - 40);
    _joystick.onGameResize(game.size);

    final fb = fireButton;
    if (fb != null) {
      (fb.button as CircleComponent).radius = 30 * scale;
      (fb.buttonDown as CircleComponent).radius = 30 * scale;
      fb
        ..size = Vector2.all(60 * scale)
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
