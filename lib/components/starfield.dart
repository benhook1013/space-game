import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../util/open_simplex_noise.dart';

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
  });

  /// Camera movement multiplier. Smaller values appear further away.
  final double parallax;

  /// Multiplier applied to star density. Values >1 increase star count.
  /// Values ≤0 disable the layer.
  final double density;

  /// Speed factor for star alpha animation.
  final double twinkleSpeed;

  /// Maximum tiles retained in the LRU cache.
  final int maxCacheTiles;

  /// Palette of possible star colours.
  final List<Color> palette;

  /// Minimum star brightness (0-255).
  final int minBrightness;

  /// Maximum star brightness (0-255).
  final int maxBrightness;
}

/// Deterministic world-space starfield rendered behind gameplay.
class StarfieldComponent extends Component with HasGameReference<FlameGame> {
  StarfieldComponent({
    int seed = 0,
    this.debugDrawTiles = false,
    List<StarfieldLayerConfig>? layers,
    this.tileSize = Constants.starfieldTileSize,
  })  : _seed = seed,
        _layers =
            layers ?? const [StarfieldLayerConfig(parallax: 1, density: 1)],
        super(priority: -1);

  final int _seed;

  /// Layer configurations.
  final List<StarfieldLayerConfig> _layers;

  /// Size of each generated starfield tile.
  final double tileSize;

  final Paint _starPaint = Paint();

  /// Whether to draw debug outlines around generated tiles.
  bool debugDrawTiles;

  static final Paint _outlinePaint = Paint()
    ..color = Constants.starfieldTileOutlineColor
    ..style = PaintingStyle.stroke;

  late final Image _starImage;
  late final Rect _starSrcRect;
  late final double _starImageRadius;

  double _time = 0;

  final List<_LayerState> _layerStates = [];

  @override
  Future<void> onLoad() async {
    _starImage = await _buildStarImage();
    _starSrcRect = Rect.fromLTWH(
        0, 0, _starImage.width.toDouble(), _starImage.height.toDouble());
    _starImageRadius = _starImage.width / 2;
    for (var i = 0; i < _layers.length; i++) {
      final cfg = _layers[i];
      _layerStates.add(_LayerState(cfg, _seed + i));
    }
    super.onLoad();
  }

  /// Exposes the current cache size for tests.
  @visibleForTesting
  int debugCacheSize([int layerIndex = 0]) =>
      _layerStates[layerIndex].cache.length;

  /// Awaits all pending tile generations. Used in tests.
  @visibleForTesting
  Future<void> debugWaitForPending() async {
    await Future.wait(
        _layerStates.expand((l) => l.pending.values).toList(growable: false));
  }

  @override
  void update(double dt) {
    _time += dt;
    final cameraPos = game.camera.viewfinder.position;
    final viewSize = game.size;

    for (final layer in _layerStates) {
      final cfg = layer.config;
      final left = cameraPos.x * cfg.parallax - viewSize.x / 2;
      final top = cameraPos.y * cfg.parallax - viewSize.y / 2;
      final right = left + viewSize.x;
      final bottom = top + viewSize.y;

      final startX = (left / tileSize).floor() - Constants.starfieldCacheMargin;
      final endX = (right / tileSize).floor() + Constants.starfieldCacheMargin;
      final startY = (top / tileSize).floor() - Constants.starfieldCacheMargin;
      final endY = (bottom / tileSize).floor() + Constants.starfieldCacheMargin;

      for (var tx = startX; tx <= endX; tx++) {
        for (var ty = startY; ty <= endY; ty++) {
          _ensureTile(layer, tx, ty);
        }
      }

      _prune(layer);
    }
  }

  @override
  void render(Canvas canvas) {
    final cameraPos = game.camera.viewfinder.position;
    final viewSize = game.size;

    for (final layer in _layerStates) {
      final cfg = layer.config;
      final left = cameraPos.x * cfg.parallax - viewSize.x / 2;
      final top = cameraPos.y * cfg.parallax - viewSize.y / 2;
      final right = left + viewSize.x;
      final bottom = top + viewSize.y;

      final startX = (left / tileSize).floor();
      final endX = (right / tileSize).floor();
      final startY = (top / tileSize).floor();
      final endY = (bottom / tileSize).floor();

      canvas.save();
      canvas.translate(-left, -top);
      for (var tx = startX; tx <= endX; tx++) {
        for (var ty = startY; ty <= endY; ty++) {
          final key = math.Point(tx, ty);
          final tile = layer.cache[key];
          if (tile == null) continue;
          _touch(layer, key);
          final offsetX = tx * tileSize;
          final offsetY = ty * tileSize;
          canvas.save();
          canvas.translate(offsetX, offsetY);
          for (var i = 0; i < tile.stars.length; i++) {
            final star = tile.stars[i];
            final base = 1 - star.amplitude;
            final twinkle = math.sin(
                      _time * cfg.twinkleSpeed * star.frequency + star.phase,
                    ) *
                    star.amplitude +
                base;
            tile.colors[i] = star.color.withAlpha((twinkle * 255).round());
          }
          canvas.drawAtlas(
            _starImage,
            tile.transforms,
            tile.rects,
            tile.colors,
            BlendMode.srcOver,
            null,
            _starPaint,
          );
          if (debugDrawTiles) {
            canvas.drawRect(
              Rect.fromLTWH(
                0,
                0,
                tileSize,
                tileSize,
              ),
              _outlinePaint,
            );
          }
          canvas.restore();
        }
      }
      canvas.restore();
    }
  }

  void _ensureTile(_LayerState layer, int tx, int ty) {
    final key = math.Point(tx, ty);
    if (layer.cache.containsKey(key) || layer.pending.containsKey(key)) {
      return;
    }
    if (layer.config.density <= 0) {
      layer.cache[key] = const _Tile.empty();
      layer.lru.addLast(key);
      _prune(layer);
      return;
    }
    final noiseValue = layer.noise
        .noise2D(tx * Constants.starNoiseScale, ty * Constants.starNoiseScale);
    final density = (noiseValue + 1) / 2;
    final minDist = _lerp(
          Constants.starMinDistanceMin,
          Constants.starMinDistanceMax,
          (1 - density).toDouble(),
        ) /
        layer.config.density;
    final params = _TileParams(
      _seed,
      tx,
      ty,
      minDist,
      tileSize,
      layer.paletteValues,
      layer.config.minBrightness,
      layer.config.maxBrightness,
    );
    final future = _runTileData(params).then((data) {
      final stars = data
          .map((s) => _Star(
                Offset(s[0] as double, s[1] as double),
                s[2] as double,
                Color(s[3] as int),
                s[4] as double,
                s[5] as double,
                s[6] as double,
              ))
          .toList(growable: false);
      final transforms = stars
          .map(
            (s) => RSTransform.fromComponents(
              rotation: 0,
              scale: s.radius / _starImageRadius,
              anchorX: _starImageRadius,
              anchorY: _starImageRadius,
              translateX: s.position.dx,
              translateY: s.position.dy,
            ),
          )
          .toList(growable: false);
      final rects =
          List<Rect>.filled(stars.length, _starSrcRect, growable: false);
      final colors =
          List<Color>.filled(stars.length, const Color(0), growable: false);
      final tile = _Tile(stars, transforms, rects, colors);
      layer.cache[key] = tile;
      layer.lru.addLast(key);
      layer.pending.remove(key);
      _prune(layer);
      return tile;
    });
    layer.pending[key] = future;
  }

  void _prune(_LayerState layer) {
    while (layer.cache.length > layer.config.maxCacheTiles) {
      final oldest = layer.lru.removeFirst();
      layer.cache.remove(oldest);
    }
  }

  void _touch(_LayerState layer, math.Point<int> key) {
    final tile = layer.cache.remove(key);
    if (tile != null) {
      layer.cache[key] = tile;
      layer.lru.remove(key);
      layer.lru.addLast(key);
    }
  }

  Future<Image> _buildStarImage() async {
    final size = (Constants.starMaxSize * 2).ceil();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = const Color(0xFFFFFFFF);
    final radius = Constants.starMaxSize;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    final picture = recorder.endRecording();
    return picture.toImage(size, size);
  }

  /// Returns the radii of the stars generated for the given tile on layer 0.
  @visibleForTesting
  Iterable<double> debugTileStarRadii(int tx, int ty) {
    if (_layers.first.density <= 0) {
      return const [];
    }
    final noise = OpenSimplexNoise(_seed);
    final n = noise.noise2D(
        tx * Constants.starNoiseScale, ty * Constants.starNoiseScale);
    final density = (n + 1) / 2;
    final minDist = _lerp(
          Constants.starMinDistanceMin,
          Constants.starMinDistanceMax,
          (1 - density).toDouble(),
        ) /
        _layers.first.density;
    final cfg = _layers.first;
    final params = _TileParams(
      _seed,
      tx,
      ty,
      minDist,
      tileSize,
      cfg.palette.map((c) => c.toARGB32()).toList(growable: false),
      cfg.minBrightness,
      cfg.maxBrightness,
    );
    return _generateTileStars(params).map((s) => s.radius);
  }
}

class _LayerState {
  _LayerState(this.config, int seed)
      : noise = OpenSimplexNoise(seed),
        paletteValues =
            config.palette.map((c) => c.toARGB32()).toList(growable: false);

  final StarfieldLayerConfig config;
  final OpenSimplexNoise noise;
  final List<int> paletteValues;
  final LinkedHashMap<math.Point<int>, _Tile> cache = LinkedHashMap();
  final Map<math.Point<int>, Future<_Tile>> pending = {};
  final Queue<math.Point<int>> lru = Queue();
}

class _Tile {
  const _Tile(this.stars, this.transforms, this.rects, this.colors);
  const _Tile.empty()
      : stars = const [],
        transforms = const [],
        rects = const [],
        colors = const [];

  final List<_Star> stars;
  final List<RSTransform> transforms;
  final List<Rect> rects;
  final List<Color> colors;
}

class _Star {
  _Star(this.position, this.radius, this.color, this.phase, this.amplitude,
      this.frequency);

  final Offset position;
  final double radius;
  final Color color;
  final double phase;
  final double amplitude;
  final double frequency;
}

class _TileParams {
  /// Parameters passed to tile generation isolate. Must remain sendable.
  const _TileParams(this.seed, this.tx, this.ty, this.minDist, this.tileSize,
      this.palette, this.minBrightness, this.maxBrightness);

  final int seed;
  final int tx;
  final int ty;
  final double minDist;
  final double tileSize;
  final List<int> palette;
  final int minBrightness;
  final int maxBrightness;
}

Future<List<List<num>>> _runTileData(_TileParams params) =>
    Isolate.run(() => _generateTileStarData(params));

List<_Star> _generateTileStars(_TileParams params) {
  final raw = _generateTileStarData(params);
  return raw
      .map((s) => _Star(
            Offset(s[0] as double, s[1] as double),
            s[2] as double,
            Color(s[3] as int),
            s[4] as double,
            s[5] as double,
            s[6] as double,
          ))
      .toList(growable: false);
}

List<List<num>> _generateTileStarData(_TileParams params) {
  final seed = params.seed;
  final tx = params.tx;
  final ty = params.ty;
  final minDist = params.minDist;
  final tileSize = params.tileSize;
  if (minDist.isInfinite || minDist.isNaN) {
    return const <List<num>>[];
  }
  final rnd = math.Random(seed ^ tx ^ (ty << 16));
  final samples = _poisson(tileSize, minDist, rnd);
  final data = samples
      .map((o) => _randomStarData(
            o,
            rnd,
            params.palette,
            params.minBrightness,
            params.maxBrightness,
          ))
      .toList()
    ..sort((a, b) => (a[2] as double).compareTo(b[2] as double));
  return data;
}

List<Offset> _poisson(double size, double minDist, math.Random rnd,
    {int maxAttempts = 30}) {
  final cellSize = minDist / math.sqrt2;
  final gridSize = (size / cellSize).ceil();
  final grid = List<Offset?>.filled(gridSize * gridSize, null);
  final active = <Offset>[];
  final samples = <Offset>[];

  Offset first = Offset(rnd.nextDouble() * size, rnd.nextDouble() * size);
  int gi = _gridIndex(first, cellSize, gridSize);
  grid[gi] = first;
  active.add(first);
  samples.add(first);

  while (active.isNotEmpty) {
    final index = rnd.nextInt(active.length);
    final point = active[index];
    bool found = false;
    for (int i = 0; i < maxAttempts; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final radius = minDist + rnd.nextDouble() * minDist;
      final candidate = Offset(
        point.dx + math.cos(angle) * radius,
        point.dy + math.sin(angle) * radius,
      );
      if (candidate.dx >= 0 &&
          candidate.dx < size &&
          candidate.dy >= 0 &&
          candidate.dy < size) {
        final gx = (candidate.dx / cellSize).floor();
        final gy = (candidate.dy / cellSize).floor();
        bool ok = true;
        for (int x = gx - 2; x <= gx + 2 && ok; x++) {
          for (int y = gy - 2; y <= gy + 2 && ok; y++) {
            if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
              final neighbor = grid[x + y * gridSize];
              if (neighbor != null &&
                  (neighbor - candidate).distance < minDist) {
                ok = false;
              }
            }
          }
        }
        if (ok) {
          grid[gx + gy * gridSize] = candidate;
          active.add(candidate);
          samples.add(candidate);
          found = true;
          break;
        }
      }
    }
    if (!found) {
      active.removeAt(index);
    }
  }

  return samples;
}

List<num> _randomStarData(Offset position, math.Random rnd, List<int> palette,
    int minBrightness, int maxBrightness) {
  final roll = rnd.nextDouble();
  double radius;
  if (roll < 0.8) {
    radius = Constants.starMaxSize * 0.25;
  } else if (roll < 0.99) {
    radius = Constants.starMaxSize * 0.5;
  } else {
    radius = Constants.starMaxSize;
  }

  final baseColor = palette[rnd.nextInt(palette.length)];
  final brightness =
      minBrightness + rnd.nextInt(maxBrightness - minBrightness + 1);
  final r = ((baseColor >> 16) & 0xFF) * brightness ~/ 255;
  final g = ((baseColor >> 8) & 0xFF) * brightness ~/ 255;
  final b = (baseColor & 0xFF) * brightness ~/ 255;
  final color = 0xFF000000 | (r << 16) | (g << 8) | b;
  final phase = rnd.nextDouble() * math.pi * 2;
  final amplitude = 0.3 + rnd.nextDouble() * 0.2; // 0.3..0.5
  final frequency = 0.8 + rnd.nextDouble() * 0.4; // 0.8..1.2
  return [
    position.dx,
    position.dy,
    radius,
    color,
    phase,
    amplitude,
    frequency,
  ];
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

int _gridIndex(Offset p, double cellSize, int gridSize) =>
    (p.dx / cellSize).floor() + (p.dy / cellSize).floor() * gridSize;
