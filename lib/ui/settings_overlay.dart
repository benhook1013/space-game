import 'package:flutter/material.dart';

import '../game/space_game.dart';
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
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(spacing),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameText(
                    'UI Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 1,
                  ),
                  SizedBox(height: spacing),
                  GameText(
                    'HUD Scaling',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
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
                  SizedBox(height: spacing),
                  ElevatedButton(
                    onPressed: settings.reset,
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
                ],
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
}
