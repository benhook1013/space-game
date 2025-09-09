import 'package:flutter/material.dart';

import '../game/space_game.dart';
import '../theme/star_palette.dart';
import 'game_text.dart';
import 'overlay_widgets.dart';

/// Overlay providing runtime UI scaling and range sliders, grouped into
/// sections for clarity.
class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({super.key, required this.game});

  final SpaceGame game;

  static const String id = 'settingsOverlay';
  static const double _maxWidthFraction = 0.8;
  static const double _fullWidthBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final settings = game.settingsService;
    return OverlayLayout(
      builder: (context, spacing, iconSize) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final maxWidth = width > _fullWidthBreakpoint
                ? width * _maxWidthFraction
                : width;
            return Container(
              width: maxWidth,
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight,
              ),
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.5),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(spacing),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GameText(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(height: spacing),
                    GameText(
                      'Audio',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(height: spacing),
                    _buildSlider(
                      context,
                      'Volume',
                      game.audioService.volume,
                      spacing,
                      min: 0,
                      max: 1,
                    ),
                    GameText(
                      'HUD Scaling',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(height: spacing),
                    _buildSlider(
                      context,
                      'HUD Buttons',
                      settings.hudButtonScale,
                      spacing,
                    ),
                    _buildSlider(
                      context,
                      'Minimap',
                      settings.minimapScale,
                      spacing,
                    ),
                    _buildSlider(
                      context,
                      'Text',
                      settings.textScale,
                      spacing,
                    ),
                    _buildSlider(
                      context,
                      'Joypad',
                      settings.joystickScale,
                      spacing,
                    ),
                    GameText(
                      'Range Scaling',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(height: spacing),
                    _buildSlider(
                      context,
                      'Targeting Range',
                      settings.targetingRange,
                      spacing,
                      min: 50,
                      max: 600,
                    ),
                    _buildSlider(
                      context,
                      'Tractor Range',
                      settings.tractorRange,
                      spacing,
                      min: 50,
                      max: 600,
                    ),
                    _buildSlider(
                      context,
                      'Mining Range',
                      settings.miningRange,
                      spacing,
                      min: 50,
                      max: 600,
                    ),
                    GameText(
                      'Performance',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(height: spacing),
                    _buildSlider(
                      context,
                      'Starfield Tile',
                      settings.starfieldTileSize,
                      spacing,
                      min: 256,
                      max: 1024,
                    ),
                    _buildSlider(
                      context,
                      'Star Density',
                      settings.starfieldDensity,
                      spacing,
                      min: 0,
                      max: 2,
                    ),
                    _buildSlider(
                      context,
                      'Star Brightness',
                      settings.starfieldBrightness,
                      spacing,
                      min: 0,
                      max: 1,
                    ),
                    _buildSlider(
                      context,
                      'Star Gamma',
                      settings.starfieldGamma,
                      spacing,
                      min: 0.5,
                      max: 2.5,
                    ),
                    _buildPaletteDropdown(
                      context,
                      'Star Palette',
                      settings.starfieldPalette,
                      spacing,
                    ),
                    SizedBox(height: spacing),
                    ElevatedButton(
                      onPressed: () {
                        settings.reset();
                        game.audioService.setMasterVolume(1);
                      },
                      child: const GameText(
                        'Reset',
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: spacing),
                    ElevatedButton(
                      onPressed: game.toggleSettings,
                      child: const GameText(
                        'Close',
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: spacing),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    ValueNotifier<double> notifier,
    double spacing, {
    double min = 0.5,
    double max = 2.0,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: notifier,
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameText('$label: ${value.toStringAsFixed(2)}'),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) => notifier.value = v,
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildPaletteDropdown(
    BuildContext context,
    String label,
    ValueNotifier<StarPalette> notifier,
    double spacing,
  ) {
    return ValueListenableBuilder<StarPalette>(
      valueListenable: notifier,
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameText(label),
          DropdownButton<StarPalette>(
            value: value,
            items: [
              for (final p in StarPalette.values)
                DropdownMenuItem(
                  value: p,
                  child: GameText(p.label),
                )
            ],
            onChanged: (p) {
              if (p != null) notifier.value = p;
            },
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }
}
