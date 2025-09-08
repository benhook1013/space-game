import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../util/open_simplex_noise.dart';

/// Deterministic world-space starfield rendered behind gameplay.
class StarfieldComponent extends Component with HasGameReference<FlameGame> {
  StarfieldComponent({int seed = 0, this.debugDrawTiles = false})
      : _seed = seed,
        super(priority: -1);

  final int _seed;
  late final OpenSimplexNoise _noise = OpenSimplexNoise(_seed);
  final Map<math.Point<int>, Picture> _cache = {};

  /// Whether to draw debug outlines around generated tiles.
  final bool debugDrawTiles;

  static final Paint _outlinePaint = Paint()
    ..color = const Color(0x40FFFFFF)
    ..style = PaintingStyle.stroke;

  /// Exposes the current cache size for tests.
  @visibleForTesting
  int get debugCacheSize => _cache.length;

  @override
  void render(Canvas canvas) {
    final cameraPos = game.camera.viewfinder.position;
    final viewSize = game.size;
    final left = cameraPos.x - viewSize.x / 2;
    final top = cameraPos.y - viewSize.y / 2;
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
        final picture =
            _cache.putIfAbsent(key, () => _generateTilePicture(tx, ty));
        final offsetX = tx * Constants.starfieldTileSize;
        final offsetY = ty * Constants.starfieldTileSize;
        canvas.save();
        canvas.translate(offsetX, offsetY);
        canvas.drawPicture(picture);
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

    _cache.removeWhere((key, picture) {
      final keep = key.x >= startX - Constants.starfieldCacheMargin &&
          key.x <= endX + Constants.starfieldCacheMargin &&
          key.y >= startY - Constants.starfieldCacheMargin &&
          key.y <= endY + Constants.starfieldCacheMargin;
      if (!keep) {
        picture.dispose();
      }
      return !keep;
    });
  }

  @override
  void onRemove() {
    for (final pic in _cache.values) {
      pic.dispose();
    }
    _cache.clear();
    super.onRemove();
  }

  Picture _generateTilePicture(int tx, int ty) {
    final recorder = PictureRecorder();
    final tileCanvas = Canvas(recorder);
    for (final star in _tileStars(tx, ty)) {
      tileCanvas.drawCircle(star.position, star.radius, star.paint);
    }
    return recorder.endRecording();
  }

  List<_Star> _tileStars(int tx, int ty) {
    final rnd = math.Random(_seed ^ tx ^ (ty << 16));
    final noise = _noise.noise2D(
        tx * Constants.starNoiseScale, ty * Constants.starNoiseScale);
    final density = (noise + 1) / 2; // 0..1
    final minDist = _lerp(
      Constants.starMinDistanceMin,
      Constants.starMinDistanceMax,
      (1 - density).toDouble(),
    );
    final samples = _poisson(Constants.starfieldTileSize, minDist, rnd);
    final stars = samples.map((o) => _randomStar(o, rnd)).toList()
      ..sort((a, b) => a.radius.compareTo(b.radius));
    return stars;
  }

  /// Returns the radii of the stars generated for the given tile.
  @visibleForTesting
  Iterable<double> debugTileStarRadii(int tx, int ty) =>
      _tileStars(tx, ty).map((s) => s.radius);

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

    final jitter = rnd.nextInt(25);
    Color color;
    if (rnd.nextBool()) {
      // blue tint
      color = Color.fromARGB(
        255,
        brightness,
        brightness,
        math.min(255, brightness + jitter),
      );
    } else {
      // yellow tint
      color = Color.fromARGB(
        255,
        math.min(255, brightness + jitter),
        math.min(255, brightness + jitter),
        brightness,
      );
    }

    return _Star(position, radius, Paint()..color = color);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  int _gridIndex(Offset p, double cellSize, int gridSize) =>
      (p.dx / cellSize).floor() + (p.dy / cellSize).floor() * gridSize;
}

class _Star {
  _Star(this.position, this.radius, this.paint);
  final Offset position;
  final double radius;
  final Paint paint;
}
