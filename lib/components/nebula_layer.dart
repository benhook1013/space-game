import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../util/open_simplex_noise.dart';

/// Noise-driven ambience overlay rendered above the starfield.
class NebulaLayer extends Component
    with HasGameReference<FlameGame>
    implements OpacityProvider {
  NebulaLayer({
    this.parallax = 0.6,
    this.noiseScale = 0.006,
    this.driftSpeed = 0.08,
    this.driftAmplitude = 48,
    this.colorCycleSpeed = 0.08,
    this.tileSize = 512,
    this.maxAlpha = 0.45,
    this.edgeFeather = 0.12,
    this.cutoff = 0.42,
    double intensity = 0.5,
    Color? primaryTint,
    Color? secondaryTint,
    int? seed,
  })  : _intensity = intensity,
        _primaryTint = primaryTint ?? const Color(0xFF7CC0FF),
        _secondaryTint = secondaryTint ?? const Color(0xFFFFA8FF),
        _seed = seed ?? 0,
        super(priority: -1);

  /// Parallax multiplier relative to the camera.
  final double parallax;

  /// Scale applied to noise input coordinates.
  final double noiseScale;

  /// Speed of the slow drift applied to the texture.
  final double driftSpeed;

  /// Maximum drift offset in logical pixels.
  final double driftAmplitude;

  /// Speed of the tint crossfade.
  final double colorCycleSpeed;

  /// Size of the cached noise tile in logical pixels.
  final int tileSize;

  /// Maximum opacity applied to the generated noise (0-1).
  final double maxAlpha;

  /// Proportion of the tile width/height used to feather edges and hide seams.
  final double edgeFeather;

  /// Noise threshold below which the layer is fully transparent.
  final double cutoff;

  final int _seed;

  Image? _tile;
  final Paint _paint = Paint();
  double _time = 0;
  double _intensity;
  double _opacity = 1;
  double _visibility = 1;
  Color _primaryTint;
  Color _secondaryTint;

  @override
  double get opacity => _opacity;

  @override
  set opacity(double value) => _opacity = value.clamp(0, 1);

  /// Adjusts the intensity multiplier (0-1).
  void setIntensity(double value) => _intensity = value.clamp(0, 1).toDouble();

  /// Sets whether the layer should be drawn (used to hide it in debug mode).
  void setDebugVisibility(bool visible) => _visibility = visible ? 1 : 0;

  /// Updates the tint colours without rebuilding tiles.
  void updatePalette(Color primary, Color secondary) {
    _primaryTint = primary;
    _secondaryTint = secondary;
  }

  @visibleForTesting
  double get effectiveOpacity =>
      (_intensity * _opacity * _visibility).clamp(0, 1).toDouble();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _tile = await _generateNebulaTile();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final tile = _tile;
    if (tile == null) {
      return;
    }
    final alpha = effectiveOpacity;
    if (alpha <= 0) {
      return;
    }

    final cameraPos = game.camera.viewfinder.position;
    final viewSize = game.size;
    final driftX = math.sin(_time * driftSpeed) * driftAmplitude;
    final driftY = math.cos(_time * driftSpeed) * driftAmplitude;
    final baseX = -cameraPos.x * parallax + driftX - viewSize.x / 2;
    final baseY = -cameraPos.y * parallax + driftY - viewSize.y / 2;

    final cycle = (math.sin(_time * colorCycleSpeed) + 1) / 2;
    final tint = Color.lerp(_primaryTint, _secondaryTint, cycle)!
        .withOpacity(alpha * maxAlpha);
    _paint
      ..color = const Color(0xFFFFFFFF)
      ..colorFilter = ColorFilter.mode(tint, BlendMode.modulate);

    final startX = (baseX / tileSize).floor() - 1;
    final endX = ((baseX + viewSize.x) / tileSize).ceil() + 1;
    final startY = (baseY / tileSize).floor() - 1;
    final endY = ((baseY + viewSize.y) / tileSize).ceil() + 1;

    for (var tx = startX; tx <= endX; tx++) {
      for (var ty = startY; ty <= endY; ty++) {
        final destX = tx * tileSize + baseX % tileSize;
        final destY = ty * tileSize + baseY % tileSize;
        canvas.drawImage(tile, Offset(destX, destY), _paint);
      }
    }
  }

  Future<Image> _generateNebulaTile() async {
    final noise = OpenSimplexNoise(_seed);
    final bytes = Uint8List(tileSize * tileSize * 4);
    var i = 0;
    for (var y = 0; y < tileSize; y++) {
      for (var x = 0; x < tileSize; x++) {
        final nx = x * noiseScale;
        final ny = y * noiseScale;
        final base = (noise.noise2D(nx, ny) + 1) / 2;
        final wisps = (noise.noise2D(nx * 0.75 + 80, ny * 0.75 - 120) + 1) / 2;
        final detail = (noise.noise2D(nx * 2.4 - 200, ny * 2.4 + 60) + 1) / 2;
        var value = base * 0.55 + wisps * 0.25 + detail * 0.2;
        value = ((value - cutoff) / (1 - cutoff)).clamp(0, 1);

        final edge = _edgeMask(x, y);
        final faded = math.pow(value * edge, 1.25) as double;
        final alpha = (faded * 255).clamp(0, 255).toInt();
        bytes[i++] = 255;
        bytes[i++] = 255;
        bytes[i++] = 255;
        bytes[i++] = alpha;
      }
    }

    final completer = Completer<Image>();
    decodeImageFromPixels(
      bytes,
      tileSize,
      tileSize,
      PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  double _edgeMask(int x, int y) {
    final edgeDistance = math.min(
      math.min(x, tileSize - 1 - x),
      math.min(y, tileSize - 1 - y),
    );
    final featherPx = (tileSize * edgeFeather).clamp(1, tileSize.toDouble());
    final mask = (edgeDistance / featherPx).clamp(0, 1);
    return math.pow(mask, 1.1).toDouble();
  }

  @override
  void onRemove() {
    _tile?.dispose();
    super.onRemove();
  }
}
