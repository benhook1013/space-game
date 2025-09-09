import 'package:flutter/painting.dart';

/// Available colour palettes for the starfield.
///
/// These palettes tint the procedurally generated stars and can be swapped at
/// runtime for accessibility or stylistic variety.
enum StarPalette {
  /// Original multicolour palette.
  classic,

  /// Cooler blues and purples for a dusk-like tone.
  dusk,

  /// Single white tone for high contrast.
  monochrome,
}

extension StarPaletteColors on StarPalette {
  /// Returns the list of colours associated with this palette.
  List<Color> get colors {
    switch (this) {
      case StarPalette.classic:
        return const [
          Color(0xFFFFFFFF),
          Color(0xFFFFAAAA),
          Color(0xFFFFFFAA),
          Color(0xFFAAAFFF),
        ];
      case StarPalette.dusk:
        return const [
          Color(0xFFB0E0FF),
          Color(0xFF8090FF),
          Color(0xFF4050A0),
          Color(0xFFE0A0FF),
        ];
      case StarPalette.monochrome:
        return const [Color(0xFFFFFFFF)];
    }
  }

  /// Human-readable label for UI selection.
  String get label {
    switch (this) {
      case StarPalette.classic:
        return 'Classic';
      case StarPalette.dusk:
        return 'Dusk';
      case StarPalette.monochrome:
        return 'Monochrome';
    }
  }
}
