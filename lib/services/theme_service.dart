import 'package:flutter/material.dart';

import '../theme/game_colors.dart';

/// Manages the current [ThemeMode] and provides the app-wide [ThemeData].
class ThemeService extends ChangeNotifier {
  ThemeService() : _themeMode = ThemeMode.system;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  /// Toggles between light and dark themes.
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Light theme built from a seed colour and custom [GameColors].
  ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            side: BorderSide(color: Colors.grey.shade500, width: 2),
          ),
        ),
        extensions: const <ThemeExtension<dynamic>>[
          GameColors(
            miningLaser: Colors.lightGreenAccent,
            enemyLaser: Colors.redAccent,
          ),
        ],
      );

  /// Dark theme variant with its own [ColorScheme] and [GameColors].
  ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade600,
            side: const BorderSide(color: Colors.grey, width: 2),
          ),
        ),
        extensions: const <ThemeExtension<dynamic>>[
          GameColors(
            miningLaser: Colors.greenAccent,
            enemyLaser: Colors.red,
          ),
        ],
      );

  /// Convenience getter for the active [ColorScheme].
  ColorScheme get colorScheme =>
      (themeMode == ThemeMode.dark ? darkTheme : lightTheme).colorScheme;

  /// Convenience getter for the active [GameColors] extension.
  GameColors get gameColors => (themeMode == ThemeMode.dark
      ? darkTheme.extension<GameColors>()
      : lightTheme.extension<GameColors>())!;
}
