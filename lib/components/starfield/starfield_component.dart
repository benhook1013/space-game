import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../../constants.dart';
import '../../util/open_simplex_noise.dart';
import 'starfield_cache.dart' as cache;
import 'starfield_config.dart';
import 'starfield_renderer.dart';
import 'starfield_worker.dart';

/// Deterministic world-space starfield rendered behind gameplay.
class StarfieldComponent extends Component
    with HasGameReference<FlameGame>
    implements OpacityProvider {
  StarfieldComponent({
    int seed = 0,
    this.debugDrawTiles = false,
    List<StarfieldLayerConfig>? layers,
    this.tileSize = Constants.starfieldTileSize,
    this.densityMultiplier = 1,
    this.brightnessMultiplier = 1,
    this.gamma = 1,
    double opacity = 1,
  })  : _seed = seed,
        _layers =
            layers ?? const [StarfieldLayerConfig(parallax: 1, density: 1)],
        _opacity = opacity,
        super(priority: -1);

  final int _seed;

  /// Layer configurations.
  final List<StarfieldLayerConfig> _layers;

  /// Size of each generated starfield tile.
  final double tileSize;

  /// Multiplier applied to layer densities.
  final double densityMultiplier;

  /// Multiplier applied to star brightness (0-1).
  final double brightnessMultiplier;

  /// Global multiplier applied to layer gamma values.
  final double gamma;

  final Paint _starPaint = Paint();

  double _opacity = 1;

  @override
  double get opacity => _opacity;

  @override
  set opacity(double value) => _opacity = value.clamp(0, 1);

  /// Whether to draw debug outlines around generated tiles.
  bool debugDrawTiles;

  static final Paint outlinePaint = Paint()
    ..color = Constants.starfieldTileOutlineColor
    ..style = PaintingStyle.stroke;

  late final Image _starImage;
  late final double _starImageRadius;
  late final StarfieldRenderer _renderer;

  double _time = 0;

  int _leftMargin = Constants.starfieldCacheMargin;
  int _rightMargin = Constants.starfieldCacheMargin;
  int _topMargin = Constants.starfieldCacheMargin;
  int _bottomMargin = Constants.starfieldCacheMargin;
  Vector2? _lastCameraPos;

  final List<cache.LayerState> _layerStates = [];

  Vector2 _cameraPositionForLayer(StarfieldLayerConfig config) {
    final drift = config.drift;
    if (drift == Offset.zero) {
      return game.camera.viewfinder.position;
    }
    return game.camera.viewfinder.position +
        Vector2(drift.dx, drift.dy) * _time;
  }

  @override
  Future<void> onLoad() async {
    _starImage = await cache.buildStarImage();
    _starImageRadius = _starImage.width / 2;
    _renderer = StarfieldRenderer(_starImage);
    for (var i = 0; i < _layers.length; i++) {
      final cfg = _layers[i];
      _layerStates.add(cache.LayerState(cfg, _seed + i));
    }
    await cache.preloadTiles(
      _layerStates,
      game,
      tileSize,
      _leftMargin,
      _rightMargin,
      _topMargin,
      _bottomMargin,
      _seed,
      densityMultiplier,
      brightnessMultiplier,
      gamma,
      _starImage,
      _starImageRadius,
      _cameraPositionForLayer,
    );
    _lastCameraPos = game.camera.viewfinder.position.clone();
    super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _leftMargin = Constants.starfieldCacheMargin;
    _rightMargin = Constants.starfieldCacheMargin;
    _topMargin = Constants.starfieldCacheMargin;
    _bottomMargin = Constants.starfieldCacheMargin;
    unawaited(cache.preloadTiles(
      _layerStates,
      game,
      tileSize,
      _leftMargin,
      _rightMargin,
      _topMargin,
      _bottomMargin,
      _seed,
      densityMultiplier,
      brightnessMultiplier,
      gamma,
      _starImage,
      _starImageRadius,
      _cameraPositionForLayer,
    ));
    _lastCameraPos = game.camera.viewfinder.position.clone();
  }

  @override
  void onRemove() {
    for (final layer in _layerStates) {
      layer.pending.clear();
      layer.cache.clear();
      layer.lru.clear();
    }
    super.onRemove();
  }

  /// Exposes the current cache size for tests.
  @visibleForTesting
  int debugCacheSize([int layerIndex = 0]) =>
      _layerStates[layerIndex].cache.length;

  /// Awaits all pending tile generations. Used in tests.
  @visibleForTesting
  Future<void> debugWaitForPending() async {
    final pendingTiles = _layerStates.expand((layer) => layer.pending.values);
    if (pendingTiles.isEmpty) {
      return;
    }
    await Future.wait(pendingTiles);
  }

  @visibleForTesting
  Set<math.Point<int>> debugCachedTiles([int layerIndex = 0]) =>
      _layerStates[layerIndex].cache.keys.toSet();

  @override
  void update(double dt) {
    _time += dt;
    final cameraPos = game.camera.viewfinder.position;
    final viewSize = game.size;

    final movement =
        _lastCameraPos == null ? Vector2.zero() : cameraPos - _lastCameraPos!;
    final moveTilesX = (movement.x.abs() / tileSize).ceil();
    final moveTilesY = (movement.y.abs() / tileSize).ceil();
    _leftMargin = math.min(
      Constants.starfieldCacheMargin + (movement.x < 0 ? moveTilesX : 0),
      Constants.starfieldMaxCacheMargin,
    );
    _rightMargin = math.min(
      Constants.starfieldCacheMargin + (movement.x > 0 ? moveTilesX : 0),
      Constants.starfieldMaxCacheMargin,
    );
    _topMargin = math.min(
      Constants.starfieldCacheMargin + (movement.y < 0 ? moveTilesY : 0),
      Constants.starfieldMaxCacheMargin,
    );
    _bottomMargin = math.min(
      Constants.starfieldCacheMargin + (movement.y > 0 ? moveTilesY : 0),
      Constants.starfieldMaxCacheMargin,
    );
    _lastCameraPos = cameraPos.clone();

    for (final layer in _layerStates) {
      final cfg = layer.config;
      final layerCameraPos = _cameraPositionForLayer(cfg);
      final left = layerCameraPos.x * cfg.parallax - viewSize.x / 2;
      final top = layerCameraPos.y * cfg.parallax - viewSize.y / 2;
      final right = left + viewSize.x;
      final bottom = top + viewSize.y;

      final startX = (left / tileSize).floor() - _leftMargin;
      final endX = (right / tileSize).floor() + _rightMargin;
      final startY = (top / tileSize).floor() - _topMargin;
      final endY = (bottom / tileSize).floor() + _bottomMargin;

      for (var tx = startX; tx <= endX; tx++) {
        for (var ty = startY; ty <= endY; ty++) {
          cache.ensureTile(
            layer,
            tx,
            ty,
            _seed,
            tileSize,
            _starImage,
            _starImageRadius,
            densityMultiplier,
            brightnessMultiplier,
            gamma,
          );
        }
      }

      cache.prune(
        layer,
        layerCameraPos,
        viewSize,
        tileSize,
        _leftMargin,
        _rightMargin,
        _topMargin,
        _bottomMargin,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    final viewSize = game.size;
    _starPaint.color = Color.fromRGBO(255, 255, 255, opacity);
    for (final layer in _layerStates) {
      final layerCameraPos = _cameraPositionForLayer(layer.config);
      cache.prune(layer, layerCameraPos, viewSize, tileSize, _leftMargin,
          _rightMargin, _topMargin, _bottomMargin);
    }
    _renderer.render(
      canvas,
      _layerStates,
      _cameraPositionForLayer,
      viewSize,
      tileSize,
      _time,
      _starPaint,
      outlinePaint,
      debugDrawTiles,
    );
  }

  /// Returns the radii of the stars generated for the given tile on layer 0.
  @visibleForTesting
  Iterable<double> debugTileStarRadii(int tx, int ty) {
    final firstLayer = _layers.first;
    if (firstLayer.density <= 0) {
      return const [];
    }

    final noise = OpenSimplexNoise(_seed);
    final noiseValue = noise.noise2D(
        tx * Constants.starNoiseScale, ty * Constants.starNoiseScale);
    final density = (noiseValue + 1) / 2;
    final minDist = _lerp(
          Constants.starMinDistanceMin,
          Constants.starMinDistanceMax,
          (1 - density).toDouble(),
        ) /
        firstLayer.density;

    final params = TileParams(
      _seed,
      tx,
      ty,
      minDist,
      tileSize,
      firstLayer.palette.map((c) => c.toARGB32()).toList(growable: false),
      firstLayer.minBrightness,
      firstLayer.maxBrightness,
      firstLayer.gamma * gamma,
    );

    return generateTileStars(params, firstLayer.twinkleSpeed)
        .map((star) => star.radius);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}
