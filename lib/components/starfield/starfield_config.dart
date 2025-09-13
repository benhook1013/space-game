import 'dart:ui';

/// Configuration for a single starfield layer.
class StarfieldLayerConfig {
  const StarfieldLayerConfig({
    this.parallax = 1,
    this.density = 1,
    this.twinkleSpeed = 1,
    this.maxCacheTiles = 64,
    this.palette = const [
      Color(0xFFFFFFFF),
      Color(0xFFFFAAAA),
      Color(0xFFFFFFAA),
      Color(0xFFAAAFFF),
    ],
    this.minBrightness = 150,
    this.maxBrightness = 255,
    this.gamma = 1,
  });

  final double parallax;
  final double density;
  final double twinkleSpeed;
  final int maxCacheTiles;
  final List<Color> palette;
  final int minBrightness;
  final int maxBrightness;
  final double gamma;
}
