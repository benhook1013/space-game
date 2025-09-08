import 'dart:async';
import 'dart:collection';
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
  });

  /// Camera movement multiplier. Smaller values appear further away.
  final double parallax;

  /// Multiplier applied to star density. Values >1 increase star count.
  final double density;

  /// Speed factor for star alpha animation.
  final double twinkleSpeed;

  /// Maximum tiles retained in the LRU cache.
  final int maxCacheTiles;
}

/// Deterministic world-space starfield rendered behind gameplay.
class StarfieldComponent extends Component with HasGameReference<FlameGame> {
  StarfieldComponent({
    int seed = 0,
    this.debugDrawTiles = false,
    List<StarfieldLayerConfig>? layers,
  })  : _seed = seed,
        _layers =
            layers ?? const [StarfieldLayerConfig(parallax: 1, density: 1)],
        super(priority: -1);

  final int _seed;

  /// Layer configurations.
  final List<StarfieldLayerConfig> _layers;

  final Paint _starPaint = Paint();

  /// Whether to draw debug outlines around generated tiles.
  bool debugDrawTiles;

  static final Paint _outlinePaint = Paint()
    ..color = Constants.starfieldTileOutlineColor
    ..style = PaintingStyle.stroke;

  double _time = 0;

  final List<_LayerState> _layerStates = [];

  @override
  Future<void> onLoad() async {
    for (final cfg in _layers) {
      _layerStates.add(_LayerState(cfg));
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

      final startX = (left / Constants.starfieldTileSize).floor() -
          Constants.starfieldCacheMargin;
      final endX = (right / Constants.starfieldTileSize).floor() +
          Constants.starfieldCacheMargin;
      final startY = (top / Constants.starfieldTileSize).floor() -
          Constants.starfieldCacheMargin;
      final endY = (bottom / Constants.starfieldTileSize).floor() +
          Constants.starfieldCacheMargin;

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

      final startX = (left / Constants.starfieldTileSize).floor();
      final endX = (right / Constants.starfieldTileSize).floor();
      final startY = (top / Constants.starfieldTileSize).floor();
      final endY = (bottom / Constants.starfieldTileSize).floor();

      canvas.save();
      canvas.translate(-left, -top);
      for (var tx = startX; tx <= endX; tx++) {
        for (var ty = startY; ty <= endY; ty++) {
          final key = math.Point(tx, ty);
          final stars = layer.cache[key];
          if (stars == null) continue;
          _touch(layer, key);
          final offsetX = tx * Constants.starfieldTileSize;
          final offsetY = ty * Constants.starfieldTileSize;
          canvas.save();
          canvas.translate(offsetX, offsetY);
          for (final star in stars) {
            final twinkle =
                math.sin(_time * cfg.twinkleSpeed + star.phase) * 0.4 + 0.6;
            _starPaint.color = star.color.withAlpha((twinkle * 255).round());
            canvas.drawCircle(star.position, star.radius, _starPaint);
          }
          if (debugDrawTiles) {
            canvas.drawRect(
              Rect.fromLTWH(
                0,
                0,
                Constants.starfieldTileSize,
                Constants.starfieldTileSize,
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
    final future =
        Future(() => _generateTileStars(_seed, tx, ty, layer.config.density));
    layer.pending[key] = future;
    future.then((stars) {
      layer.cache[key] = stars;
      layer.pending.remove(key);
      _prune(layer);
    });
  }

  void _prune(_LayerState layer) {
    while (layer.cache.length > layer.config.maxCacheTiles) {
      layer.cache.remove(layer.cache.keys.first);
    }
  }

  void _touch(_LayerState layer, math.Point<int> key) {
    final stars = layer.cache.remove(key);
    if (stars != null) {
      layer.cache[key] = stars;
    }
  }

  /// Returns the radii of the stars generated for the given tile on layer 0.
  @visibleForTesting
  Iterable<double> debugTileStarRadii(int tx, int ty) =>
      _generateTileStars(_seed, tx, ty, _layers.first.density)
          .map((s) => s.radius);
}

class _LayerState {
  _LayerState(this.config);

  final StarfieldLayerConfig config;
  final LinkedHashMap<math.Point<int>, List<_Star>> cache = LinkedHashMap();
  final Map<math.Point<int>, Future<List<_Star>>> pending = {};
}

class _Star {
  _Star(this.position, this.radius, this.color, this.phase);

  final Offset position;
  final double radius;
  final Color color;
  final double phase;
}

List<_Star> _generateTileStars(
    int seed, int tx, int ty, double densityMultiplier) {
  final noise = OpenSimplexNoise(seed);
  final rnd = math.Random(seed ^ tx ^ (ty << 16));
  final n = noise.noise2D(
      tx * Constants.starNoiseScale, ty * Constants.starNoiseScale);
  final density = (n + 1) / 2; // 0..1
  final minDist = _lerp(
        Constants.starMinDistanceMin,
        Constants.starMinDistanceMax,
        (1 - density).toDouble(),
      ) /
      densityMultiplier;
  final samples = _poisson(Constants.starfieldTileSize, minDist, rnd);
  final stars = samples.map((o) => _randomStar(o, rnd)).toList()
    ..sort((a, b) => a.radius.compareTo(b.radius));
  return stars;
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

_Star _randomStar(Offset position, math.Random rnd) {
  final roll = rnd.nextDouble();
  double radius;
  int brightness;
  if (roll < 0.8) {
    radius = Constants.starMaxSize * 0.25;
    brightness = 150 + rnd.nextInt(40);
  } else if (roll < 0.99) {
    radius = Constants.starMaxSize * 0.5;
    brightness = 180 + rnd.nextInt(60);
  } else {
    radius = Constants.starMaxSize;
    brightness = 230 + rnd.nextInt(25);
  }

  final jitter = rnd.nextInt(55);
  final hue = rnd.nextInt(4);
  int r = brightness, g = brightness, b = brightness;
  switch (hue) {
    case 0: // blue
      b = math.min(255, b + jitter);
      break;
    case 1: // yellow
      r = math.min(255, r + jitter);
      g = math.min(255, g + jitter);
      break;
    case 2: // red
      r = math.min(255, r + jitter);
      break;
    default: // white
      r = math.min(255, r + jitter);
      g = math.min(255, g + jitter);
      b = math.min(255, b + jitter);
  }

  final color = Color.fromARGB(255, r, g, b);
  final phase = rnd.nextDouble() * math.pi * 2;
  return _Star(position, radius, color, phase);
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

int _gridIndex(Offset p, double cellSize, int gridSize) =>
    (p.dx / cellSize).floor() + (p.dy / cellSize).floor() * gridSize;
