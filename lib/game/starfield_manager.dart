import 'dart:async';

import 'package:flame/game.dart';

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
  int _rebuildId = 0;
  bool _debugMode;

  /// Initialises the starfield and starts listening for setting changes.
  Future<void> init() async {
    await _buildStarfield();
    settings.starfieldTileSize.addListener(_rebuild);
    settings.starfieldDensity.addListener(_rebuild);
    settings.starfieldBrightness.addListener(_rebuild);
    settings.starfieldGamma.addListener(_rebuild);
    settings.starfieldPalette.addListener(_rebuild);
  }

  /// Returns the current starfield component if built.
  StarfieldComponent? get starfield => _starfield;

  /// Updates whether starfield tiles are outlined for debugging.
  void updateDebug(bool enabled) {
    _debugMode = enabled;
    _starfield?.debugDrawTiles = enabled;
  }

  void _rebuild() {
    _starfield?.removeFromParent();
    _starfield = null;
    final buildId = ++_rebuildId;
    unawaited(_buildStarfield(buildId: buildId));
  }

  Future<void> _buildStarfield({int? buildId}) async {
    final palette = settings.starfieldPalette.value.colors;
    final sf = await StarfieldComponent(
      debugDrawTiles: _debugMode,
      layers: [
        StarfieldLayerConfig(
          parallax: 0.2,
          density: 0.3,
          twinkleSpeed: 0.5,
          palette: palette,
        ),
        StarfieldLayerConfig(
          parallax: 0.6,
          density: 0.6,
          twinkleSpeed: 0.8,
          palette: palette,
        ),
        StarfieldLayerConfig(
          parallax: 1,
          density: 1,
          twinkleSpeed: 1,
          palette: palette,
        ),
      ],
      tileSize: settings.starfieldTileSize.value,
      densityMultiplier: settings.starfieldDensity.value,
      brightnessMultiplier: settings.starfieldBrightness.value,
      gamma: settings.starfieldGamma.value,
    );
    if (buildId != null && buildId != _rebuildId) {
      return;
    }
    _starfield = sf;
    await game.add(sf);
  }

  /// Cleans up listeners and removes the starfield from the game.
  void dispose() {
    settings.starfieldTileSize.removeListener(_rebuild);
    settings.starfieldDensity.removeListener(_rebuild);
    settings.starfieldBrightness.removeListener(_rebuild);
    settings.starfieldGamma.removeListener(_rebuild);
    settings.starfieldPalette.removeListener(_rebuild);
    _starfield?.removeFromParent();
  }
}
