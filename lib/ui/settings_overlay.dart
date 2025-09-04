import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';
import 'overlay_widgets.dart';

/// Overlay providing runtime UI scaling sliders.
class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({super.key, required this.game});

  final SpaceGame game;

  static const String id = 'settingsOverlay';

  @override
  Widget build(BuildContext context) {
    final settings = game.settingsService;
    return OverlayLayout(
      dimmed: true,
      builder: (context, spacing, iconSize) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameText(
              'UI Settings',
              style: Theme.of(context).textTheme.headlineSmall,
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
            ValueListenableBuilder<ThemeMode>(
              valueListenable: settings.themeMode,
              builder: (context, mode, _) => ListTile(
                title: const GameText('Theme', maxLines: 1),
                trailing: DropdownButton<ThemeMode>(
                  value: mode,
                  onChanged: (newMode) {
                    if (newMode != null) {
                      settings.themeMode.value = newMode;
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: GameText('System', maxLines: 1),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: GameText('Light', maxLines: 1),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: GameText('Dark', maxLines: 1),
                    ),
                  ],
                ),
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
        );
      },
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    ValueNotifier<double> notifier,
    double spacing,
  ) {
    return ValueListenableBuilder<double>(
      valueListenable: notifier,
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameText('$label: ${value.toStringAsFixed(2)}'),
          Slider(
            value: value,
            min: 0.5,
            max: 2.0,
            onChanged: (v) => notifier.value = v,
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }
}
