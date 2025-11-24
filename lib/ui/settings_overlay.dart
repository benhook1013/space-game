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
    final sections = [
      _SettingsSectionData(
        title: 'Audio',
        sliders: [
          _SliderSetting(
            'Volume',
            game.audioService.volume,
            min: 0,
            max: 1,
            format: _percentFormatter,
          ),
        ],
      ),
      _SettingsSectionData(
        title: 'HUD Scaling',
        sliders: [
          _SliderSetting(
            'HUD Buttons',
            settings.hudButtonScale,
            format: _scaleFormatter,
          ),
          _SliderSetting(
            'Minimap',
            settings.minimapScale,
            format: _scaleFormatter,
          ),
          _SliderSetting(
            'Text',
            settings.textScale,
            format: _scaleFormatter,
          ),
          _SliderSetting(
            'Joypad',
            settings.joystickScale,
            format: _scaleFormatter,
          ),
        ],
      ),
      _SettingsSectionData(
        title: 'Range Scaling',
        sliders: [
          _SliderSetting(
            'Targeting Range',
            settings.targetingRange,
            min: 50,
            max: 600,
            format: _pixelsFormatter,
          ),
          _SliderSetting(
            'Tractor Range',
            settings.tractorRange,
            min: 50,
            max: 600,
            format: _pixelsFormatter,
          ),
          _SliderSetting(
            'Mining Range',
            settings.miningRange,
            min: 50,
            max: 600,
            format: _pixelsFormatter,
          ),
        ],
      ),
      _SettingsSectionData(
        title: 'Performance',
        sliders: [
          _SliderSetting(
            'Starfield Tile',
            settings.starfieldTileSize,
            min: 256,
            max: 1024,
            format: _pixelsFormatter,
          ),
          _SliderSetting(
            'Star Density',
            settings.starfieldDensity,
            min: 0,
            max: 2,
            format: _multiplierFormatter,
          ),
          _SliderSetting(
            'Star Brightness',
            settings.starfieldBrightness,
            min: 0,
            max: 1,
            format: _percentFormatter,
          ),
          _SliderSetting(
            'Star Gamma',
            settings.starfieldGamma,
            min: 0.5,
            max: 2.5,
            format: _gammaFormatter,
          ),
        ],
        extraBuilders: [
          (spacing) => _buildPaletteDropdown(
                context,
                'Star Palette',
                settings.starfieldPalette,
                spacing,
              ),
        ],
      ),
      _SettingsSectionData(
        title: 'Ambience',
        sliders: [
          _SliderSetting(
            'Nebula Intensity',
            settings.nebulaIntensity,
            min: 0,
            max: 1,
            format: _percentFormatter,
          ),
        ],
      ),
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
                    for (final section in sections) ...[
                      _SettingsSection(
                        title: section.title,
                        sliders: section.sliders,
                        spacing: spacing,
                        extraBuilders: section.extraBuilders,
                      ),
                      SizedBox(height: spacing),
                    ],
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

String _percentFormatter(double value) => '${(value * 100).round()}%';

String _scaleFormatter(double value) => 'x${value.toStringAsFixed(2)}';

String _pixelsFormatter(double value) => '${value.round()} px';

String _multiplierFormatter(double value) => '${value.toStringAsFixed(2)}x';

String _gammaFormatter(double value) => value.toStringAsFixed(2);

String _defaultSliderValue(double value) {
  final rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.01 || value.abs() >= 50) {
    return rounded.toStringAsFixed(0);
  }
  if (value.abs() >= 10) {
    return value.toStringAsFixed(1);
  }
  return value.toStringAsFixed(2);
}

typedef _SectionChildBuilder = Widget Function(double spacing);

class _SettingsSectionData {
  const _SettingsSectionData({
    required this.title,
    this.sliders = const [],
    this.extraBuilders = const [],
  });

  final String title;
  final List<_SliderSetting> sliders;
  final List<_SectionChildBuilder> extraBuilders;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.sliders,
    required this.spacing,
    this.extraBuilders = const [],
  });

  final String title;
  final List<_SliderSetting> sliders;
  final double spacing;
  final List<_SectionChildBuilder> extraBuilders;

  @override
  Widget build(BuildContext context) {
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
        for (final slider in sliders)
          _SettingSlider(
            setting: slider,
            spacing: spacing,
          ),
        for (final buildExtra in extraBuilders) buildExtra(spacing),
      ],
    );
  }
}

class _SettingSlider extends StatelessWidget {
  const _SettingSlider({required this.setting, required this.spacing});

  final _SliderSetting setting;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: setting.notifier,
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameText('${setting.label}: ${setting.formatValue(value)}'),
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
}

class _SliderSetting {
  const _SliderSetting(
    this.label,
    this.notifier, {
    this.min = 0.5,
    this.max = 2.0,
    this.format,
  });

  final String label;
  final ValueNotifier<double> notifier;
  final double min;
  final double max;
  final String Function(double value)? format;

  String formatValue(double value) => (format ?? _defaultSliderValue)(value);
}
