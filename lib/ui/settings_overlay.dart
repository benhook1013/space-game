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
    final audioSliders = [
      _SliderSetting('Volume', game.audioService.volume, min: 0, max: 1),
    ];
    final hudSliders = [
      _SliderSetting('HUD Buttons', settings.hudButtonScale),
      _SliderSetting('Minimap', settings.minimapScale),
      _SliderSetting('Text', settings.textScale),
      _SliderSetting('Joypad', settings.joystickScale),
    ];
    final rangeSliders = [
      _SliderSetting('Targeting Range', settings.targetingRange,
          min: 50, max: 600),
      _SliderSetting('Tractor Range', settings.tractorRange, min: 50, max: 600),
      _SliderSetting('Mining Range', settings.miningRange, min: 50, max: 600),
    ];
    final performanceSliders = [
      _SliderSetting('Starfield Tile', settings.starfieldTileSize,
          min: 256, max: 1024),
      _SliderSetting('Star Density', settings.starfieldDensity, min: 0, max: 2),
      _SliderSetting('Star Brightness', settings.starfieldBrightness,
          min: 0, max: 1),
      _SliderSetting('Star Gamma', settings.starfieldGamma, min: 0.5, max: 2.5),
    ];

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
                    _buildSection(context, 'Audio', audioSliders, spacing),
                    _buildSection(context, 'HUD Scaling', hudSliders, spacing),
                    _buildSection(
                        context, 'Range Scaling', rangeSliders, spacing),
                    _buildSection(
                      context,
                      'Performance',
                      performanceSliders,
                      spacing,
                      extra: [
                        _buildPaletteDropdown(
                          context,
                          'Star Palette',
                          settings.starfieldPalette,
                          spacing,
                        ),
                      ],
                    ),
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
                      onPressed: () => game.ui.toggleSettings(),
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

  Widget _buildSection(
    BuildContext context,
    String title,
    List<_SliderSetting> sliders,
    double spacing, {
    List<Widget> extra = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GameText(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(height: spacing),
        for (final slider in sliders) _buildSlider(context, slider, spacing),
        ...extra,
      ],
    );
  }

  Widget _buildSlider(
    BuildContext context,
    _SliderSetting setting,
    double spacing,
  ) {
    return ValueListenableBuilder<double>(
      valueListenable: setting.notifier,
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameText('${setting.label}: ${value.toStringAsFixed(2)}'),
          Slider(
            value: value,
            min: setting.min,
            max: setting.max,
            onChanged: (v) => setting.notifier.value = v,
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

class _SliderSetting {
  const _SliderSetting(
    this.label,
    this.notifier, {
    this.min = 0.5,
    this.max = 2.0,
  });

  final String label;
  final ValueNotifier<double> notifier;
  final double min;
  final double max;
}
