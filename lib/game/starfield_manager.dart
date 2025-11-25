import 'dart:async';
import 'dart:ui';

import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../components/nebula_layer.dart';
import '../components/starfield.dart';
import '../services/settings_service.dart';
import '../theme/star_palette.dart';

/// Manages the background starfield and rebuilds it when settings change.
class StarfieldManager {
  StarfieldManager({
    required this.game,
    required this.settings,
    bool debugMode = false,
  }) : _debugMode = debugMode;

  /// Host game used to add the starfield component.
  final FlameGame game;

  /// Provides runtime starfield configuration values.
  final SettingsService settings;

  StarfieldComponent? _starfield;
  NebulaLayer? _nebula;
  int _rebuildId = 0;
  int _nebulaBuildId = 0;
  bool _debugMode;

  static const _fadeDuration = 0.5;
  static const _nebulaFadeDuration = 0.35;

  /// Initialises the starfield and starts listening for setting changes.
  Future<void> init() async {
    await _buildStarfield();
    await _updateNebula();
    settings.starfieldTileSize.addListener(_handleTileSizeChange);
    settings.starfieldDensity.addListener(_rebuild);
    settings.starfieldBrightness.addListener(_rebuild);
    settings.starfieldGamma.addListener(_rebuild);
    settings.starfieldPalette.addListener(_handlePaletteChange);
    settings.nebulaIntensity.addListener(_updateNebula);
  }

  /// Returns the current starfield component if built.
  StarfieldComponent? get starfield => _starfield;

  @visibleForTesting
  NebulaLayer? get nebulaLayer => _nebula;

  /// Updates whether starfield tiles are outlined for debugging.
  void updateDebug(bool enabled) {
    _debugMode = enabled;
    _starfield?.debugDrawTiles = enabled;
    _nebula?.setDebugVisibility(!enabled);
  }

  void _rebuild() {
    final previous = _starfield;
    _starfield = null;
    final buildId = ++_rebuildId;
    unawaited(_buildStarfield(buildId: buildId, previous: previous));
  }

  void _handleTileSizeChange() {
    _rebuild();
    unawaited(_updateNebula());
  }

  void _handlePaletteChange() {
    _rebuild();
    unawaited(_updateNebula());
  }

  Future<void> _buildStarfield(
      {int? buildId, StarfieldComponent? previous}) async {
    final palette = settings.starfieldPalette.value.colors;
    final sf = await StarfieldComponent(
      debugDrawTiles: _debugMode,
      layers: [
        StarfieldLayerConfig(
          parallax: 0.2,
          density: 0.3,
          twinkleSpeed: 0.5,
          drift: const Offset(-2, 0),
          palette: palette,
        ),
        StarfieldLayerConfig(
          parallax: 0.6,
          density: 0.6,
          twinkleSpeed: 0.8,
          drift: const Offset(-6, 0),
          palette: palette,
        ),
        StarfieldLayerConfig(
          parallax: 1,
          density: 1,
          twinkleSpeed: 1,
          drift: const Offset(-12, 0),
          palette: palette,
        ),
      ],
      tileSize: settings.starfieldTileSize.value,
      densityMultiplier: settings.starfieldDensity.value,
      brightnessMultiplier: settings.starfieldBrightness.value,
      gamma: settings.starfieldGamma.value,
    );
    if (buildId != null && buildId != _rebuildId) {
      // A newer rebuild was scheduled while this one was in progress.
      // Remove the stale component immediately to avoid dangling effects on
      // disposed components during tests.
      previous?.removeFromParent();
      return;
    }
    _starfield = sf;
    sf.opacity = 1;
    await game.add(sf);
    previous?.removeFromParent();
  }

  Future<void> _updateNebula() async {
    final targetIntensity =
        settings.nebulaIntensity.value.clamp(0, 1).toDouble();
    if (targetIntensity <= 0) {
      final previous = _nebula;
      _nebula = null;
      previous?.removeFromParent();
      return;
    }

    final palette = settings.starfieldPalette.value.colors;
    final primary = palette.first;
    final secondary = palette.length > 1 ? palette.last : palette.first;
    if (_nebula != null) {
      _nebula!
        ..setIntensity(targetIntensity)
        ..updatePalette(primary, secondary)
        ..setDebugVisibility(!_debugMode);
      return;
    }

    final buildId = ++_nebulaBuildId;
    final nebula = NebulaLayer(
      parallax: 0.8,
      intensity: targetIntensity,
      tileSize: settings.starfieldTileSize.value.toInt(),
      primaryTint: primary,
      secondaryTint: secondary,
      seed: settings.starfieldPalette.value.index,
    );
    await game.add(nebula);
    if (buildId != _nebulaBuildId) {
      nebula.removeFromParent();
      return;
    }
    nebula..setDebugVisibility(!_debugMode);
    _nebula = nebula;
  }

  /// Cleans up listeners and removes the starfield from the game.
  void dispose() {
    settings.starfieldTileSize.removeListener(_handleTileSizeChange);
    settings.starfieldDensity.removeListener(_rebuild);
    settings.starfieldBrightness.removeListener(_rebuild);
    settings.starfieldGamma.removeListener(_rebuild);
    settings.starfieldPalette.removeListener(_handlePaletteChange);
    settings.nebulaIntensity.removeListener(_updateNebula);
    _starfield?.removeFromParent();
    _nebula?.removeFromParent();
  }
}
