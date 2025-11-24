import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/game.dart';
import '../../constants.dart';
import '../../util/open_simplex_noise.dart';
import 'starfield_config.dart';
import 'starfield_worker.dart';

class LayerState {
  LayerState(this.config, int seed)
      : noise = OpenSimplexNoise(seed),
        paletteValues =
            config.palette.map((c) => c.toARGB32()).toList(growable: false);

  final StarfieldLayerConfig config;
  final OpenSimplexNoise noise;
  final List<int> paletteValues;
  final LinkedHashMap<math.Point<int>, Tile> cache = LinkedHashMap();
  final Map<math.Point<int>, Future<Tile>> pending = {};
  final Queue<math.Point<int>> lru = Queue();
}

class Tile {
  Tile(this.stars, this.transforms, this.rects, this.colors);
  Tile.empty()
      : stars = const [],
        transforms = Float32List(0),
        rects = Float32List(0),
        colors = Int32List(0);

  final List<Star> stars;
  final Float32List transforms;
  final Float32List rects;
  final Int32List colors;
}

Future<Image> buildStarImage() async {
  final size = (Constants.starMaxSize * 2).ceil();
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = const Color(0xFFFFFFFF);
  final radius = Constants.starMaxSize;
  canvas.drawCircle(Offset(radius, radius), radius, paint);
  final picture = recorder.endRecording();
  return picture.toImage(size, size);
}

Future<void> preloadTiles(
  List<LayerState> layers,
  FlameGame game,
  double tileSize,
  int leftMargin,
  int rightMargin,
  int topMargin,
  int bottomMargin,
  int seed,
  double densityMultiplier,
  double brightnessMultiplier,
  double gamma,
  Image starImage,
  double starImageRadius,
) async {
  final cameraPos = game.camera.viewfinder.position;
  final viewSize = game.size;
  final futures = <Future<Tile>>[];
  for (final layer in layers) {
    final cfg = layer.config;
    final left = cameraPos.x * cfg.parallax - viewSize.x / 2;
    final top = cameraPos.y * cfg.parallax - viewSize.y / 2;
    final right = left + viewSize.x;
    final bottom = top + viewSize.y;

    final startX = (left / tileSize).floor() - leftMargin;
    final endX = (right / tileSize).floor() + rightMargin;
    final startY = (top / tileSize).floor() - topMargin;
    final endY = (bottom / tileSize).floor() + bottomMargin;
    for (var tx = startX; tx <= endX; tx++) {
      for (var ty = startY; ty <= endY; ty++) {
        ensureTile(layer, tx, ty, seed, tileSize, starImage, starImageRadius,
            densityMultiplier, brightnessMultiplier, gamma);
        final pending = layer.pending[math.Point(tx, ty)];
        if (pending != null) {
          futures.add(pending);
        }
      }
    }
  }
  if (futures.isNotEmpty) {
    await Future.wait(futures);
  }
}

void ensureTile(
  LayerState layer,
  int tx,
  int ty,
  int seed,
  double tileSize,
  Image starImage,
  double starImageRadius,
  double densityMultiplier,
  double brightnessMultiplier,
  double gamma,
) {
  final key = math.Point(tx, ty);
  if (layer.cache.containsKey(key) || layer.pending.containsKey(key)) {
    return;
  }
  final effectiveDensity = layer.config.density * densityMultiplier;
  if (effectiveDensity <= 0) {
    layer.cache[key] = Tile.empty();
    layer.lru.addLast(key);
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
      effectiveDensity;
  final params = TileParams(
    seed,
    tx,
    ty,
    minDist,
    tileSize,
    layer.paletteValues,
    (layer.config.minBrightness * brightnessMultiplier).clamp(0, 255).round(),
    (layer.config.maxBrightness * brightnessMultiplier).clamp(0, 255).round(),
    layer.config.gamma * gamma,
  );
  final future = runTileData(params).then((data) {
    final stars = data
        .map((d) => Star.fromData(d, layer.config.twinkleSpeed))
        .toList(growable: false);
    final transforms = Float32List(stars.length * 4);
    final rects = Float32List(stars.length * 4);
    final colors = Int32List(stars.length);
    for (var i = 0; i < stars.length; i++) {
      final s = stars[i];
      final r = RSTransform.fromComponents(
        rotation: 0,
        scale: s.radius / starImageRadius,
        anchorX: starImageRadius,
        anchorY: starImageRadius,
        translateX: s.position.dx,
        translateY: s.position.dy,
      );
      final ti = i * 4;
      transforms[ti] = r.scos;
      transforms[ti + 1] = r.ssin;
      transforms[ti + 2] = r.tx;
      transforms[ti + 3] = r.ty;
      rects[ti] = 0;
      rects[ti + 1] = 0;
      rects[ti + 2] = starImage.width.toDouble();
      rects[ti + 3] = starImage.height.toDouble();
    }
    final tile = Tile(stars, transforms, rects, colors);
    layer.cache[key] = tile;
    layer.lru.addLast(key);
    layer.pending.remove(key);
    return tile;
  });
  layer.pending[key] = future;
}

void prune(
  LayerState layer,
  Vector2 cameraPos,
  Vector2 viewSize,
  double tileSize,
  int leftMargin,
  int rightMargin,
  int topMargin,
  int bottomMargin,
) {
  final cfg = layer.config;
  final left = cameraPos.x * cfg.parallax - viewSize.x / 2;
  final top = cameraPos.y * cfg.parallax - viewSize.y / 2;
  final right = left + viewSize.x;
  final bottom = top + viewSize.y;
  final startX = (left / tileSize).floor();
  final endX = (right / tileSize).floor();
  final startY = (top / tileSize).floor();
  final endY = (bottom / tileSize).floor();
  final visibleX = endX - startX + 1;
  final visibleY = endY - startY + 1;
  final required = (visibleX + leftMargin + rightMargin) *
      (visibleY + topMargin + bottomMargin);
  final limit = math.max(cfg.maxCacheTiles, required);
  while (layer.cache.length > limit) {
    final oldest = layer.lru.removeFirst();
    layer.cache.remove(oldest);
  }
}

void touch(LayerState layer, math.Point<int> key) {
  final tile = layer.cache.remove(key);
  if (tile != null) {
    layer.cache[key] = tile;
    layer.lru.remove(key);
    layer.lru.addLast(key);
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;
