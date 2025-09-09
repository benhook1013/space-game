import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:isolate';

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
    this.densityMultiplier = 1,
    this.brightnessMultiplier = 1,
  })  : _seed = seed,
        _layers =
            layers ?? const [StarfieldLayerConfig(parallax: 1, density: 1)],
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

  final Paint _starPaint = Paint();

  /// Whether to draw debug outlines around generated tiles.
  bool debugDrawTiles;

  static final Paint _outlinePaint = Paint()
    ..color = Constants.starfieldTileOutlineColor
    ..style = PaintingStyle.stroke;

  late final Image _starImage;
  late final double _starImageRadius;

  double _time = 0;

  final List<_LayerState> _layerStates = [];

  @override
  Future<void> onLoad() async {
    _starImage = await _buildStarImage();
    _starImageRadius = _starImage.width / 2;
    for (var i = 0; i < _layers.length; i++) {
      final cfg = _layers[i];
      _layerStates.add(_LayerState(cfg, _seed + i));
    }
    await _preloadTiles();
    super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    unawaited(_preloadTiles());
  }

  @override
  void onRemove() {
    for (final layer in _layerStates) {
      layer.pending.clear();
      layer.cache.clear();
      layer.lru.clear();
    }
    _TileWorker.instance.dispose();
    super.onRemove();
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

  Future<void> _preloadTiles() async {
    final cameraPos = game.camera.viewfinder.position;
    final viewSize = game.size;
    final futures = <Future<_Tile>>[];
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
            tile.colors[i] = ((twinkle * 255).round() << 24) | star.color;
          }
          canvas.drawRawAtlas(
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
    final effectiveDensity = layer.config.density * densityMultiplier;
    if (effectiveDensity <= 0) {
      layer.cache[key] = _Tile.empty();
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
        effectiveDensity;
    final params = _TileParams(
      _seed,
      tx,
      ty,
      minDist,
      tileSize,
      layer.paletteValues,
      (layer.config.minBrightness * brightnessMultiplier).clamp(0, 255).round(),
      (layer.config.maxBrightness * brightnessMultiplier).clamp(0, 255).round(),
    );
    final future = _runTileData(params).then((data) {
      final stars = data.map(_Star.fromData).toList(growable: false);
      final transforms = Float32List(stars.length * 4);
      final rects = Float32List(stars.length * 4);
      final colors = Int32List(stars.length);
      for (var i = 0; i < stars.length; i++) {
        final s = stars[i];
        final r = RSTransform.fromComponents(
          rotation: 0,
          scale: s.radius / _starImageRadius,
          anchorX: _starImageRadius,
          anchorY: _starImageRadius,
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
        rects[ti + 2] = _starImage.width.toDouble();
        rects[ti + 3] = _starImage.height.toDouble();
      }
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
  _Tile(this.stars, this.transforms, this.rects, this.colors);
  _Tile.empty()
      : stars = const [],
        transforms = Float32List(0),
        rects = Float32List(0),
        colors = Int32List(0);

  final List<_Star> stars;
  final Float32List transforms;
  final Float32List rects;
  final Int32List colors;
}

class _Star {
  _Star(this.position, this.radius, this.color, this.phase, this.amplitude,
      this.frequency);

  factory _Star.fromData(_StarData d) => _Star(
        Offset(d.x, d.y),
        d.radius,
        d.color,
        d.phase,
        d.amplitude,
        d.frequency,
      );

  final Offset position;
  final double radius;
  final int color;
  final double phase;
  final double amplitude;
  final double frequency;
}

/// Immutable star properties passed across isolates.
@immutable
class _StarData {
  const _StarData(this.x, this.y, this.radius, this.color, this.phase,
      this.amplitude, this.frequency);

  final double x;
  final double y;
  final double radius;
  final int color;
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

class _TileWorker {
  _TileWorker._() {
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _readyCompleter?.complete(message);
        return;
      }
      if (message is List && message.length == 2) {
        final id = message[0] as int;
        final data = message[1] as List<_StarData>;
        _pending.remove(id)?.complete(data);
      }
    });
  }

  static final _TileWorker instance = _TileWorker._();

  SendPort? _sendPort;
  final ReceivePort _receivePort = ReceivePort();
  Isolate? _isolate;
  int _id = 0;
  final Map<int, Completer<List<_StarData>>> _pending = {};
  Completer<SendPort>? _readyCompleter;
  Future<void>? _starting;

  Future<void> _ensureStarted() {
    if (_sendPort != null) {
      return Future.value();
    }
    return _starting ??= _start();
  }

  Future<void> _start() async {
    _readyCompleter = Completer<SendPort>();
    _isolate = await Isolate.spawn(_tileWorkerMain, _receivePort.sendPort);
    await _readyCompleter!.future;
    _readyCompleter = null;
    _starting = null;
  }

  Future<List<_StarData>> run(_TileParams params) async {
    if (kIsWeb) {
      return _generateTileStarData(params);
    }
    await _ensureStarted();
    final id = _id++;
    final completer = Completer<List<_StarData>>();
    _pending[id] = completer;
    _sendPort!.send([id, params]);
    return completer.future;
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    for (final c in _pending.values) {
      if (!c.isCompleted) {
        c.complete(const []);
      }
    }
    _pending.clear();
    _sendPort = null;
  }
}

@pragma('vm:entry-point')
void _tileWorkerMain(SendPort mainSendPort) {
  final port = ReceivePort();
  mainSendPort.send(port.sendPort);
  port.listen((message) {
    final id = message[0] as int;
    final params = message[1] as _TileParams;
    final result = _generateTileStarData(params);
    mainSendPort.send([id, result]);
  });
}

Future<List<_StarData>> _runTileData(_TileParams params) =>
    _TileWorker.instance.run(params);

List<_Star> _generateTileStars(_TileParams params) {
  final raw = _generateTileStarData(params);
  return raw.map(_Star.fromData).toList(growable: false);
}

List<_StarData> _generateTileStarData(_TileParams params) {
  final seed = params.seed;
  final tx = params.tx;
  final ty = params.ty;
  final minDist = params.minDist;
  final tileSize = params.tileSize;
  if (minDist.isInfinite || minDist.isNaN) {
    return const <_StarData>[];
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
    ..sort((a, b) => (a.radius).compareTo(b.radius));
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

_StarData _randomStarData(Offset position, math.Random rnd, List<int> palette,
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
  final color = (r << 16) | (g << 8) | b;
  final phase = rnd.nextDouble() * math.pi * 2;
  final amplitude = 0.3 + rnd.nextDouble() * 0.2; // 0.3..0.5
  final frequency = 0.8 + rnd.nextDouble() * 0.4; // 0.8..1.2
  return _StarData(
    position.dx,
    position.dy,
    radius,
    color,
    phase,
    amplitude,
    frequency,
  );
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

int _gridIndex(Offset p, double cellSize, int gridSize) =>
    (p.dx / cellSize).floor() + (p.dy / cellSize).floor() * gridSize;
