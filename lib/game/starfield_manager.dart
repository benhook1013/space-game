import 'dart:async';

import 'package:flame/effects.dart';
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

  static const _fadeDuration = 0.5;

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
    final previous = _starfield;
    _starfield = null;
    final buildId = ++_rebuildId;
    unawaited(_buildStarfield(buildId: buildId, previous: previous));
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
      // A newer rebuild was scheduled while this one was in progress.
      // Fade out the old component to ensure it's removed and its cache is
      // released even though this build result will be discarded.
      previous?.add(
        OpacityEffect.to(
          0,
          EffectController(duration: _fadeDuration),
          onComplete: () => previous.removeFromParent(),
        ),
      );
      return;
    }
    _starfield = sf;
    sf.opacity = previous != null ? 0 : 1;
    await game.add(sf);
    if (previous != null) {
      previous.add(
        OpacityEffect.to(
          0,
          EffectController(duration: _fadeDuration),
          onComplete: () => previous.removeFromParent(),
        ),
      );
      sf.add(
        OpacityEffect.to(
          1,
          EffectController(duration: _fadeDuration),
        ),
      );
    }
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
