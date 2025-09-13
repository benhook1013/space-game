import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../constants.dart';

@immutable
class StarData {
  const StarData(this.x, this.y, this.radius, this.color, this.phase,
      this.amplitude, this.frequency);

  final double x;
  final double y;
  final double radius;
  final int color;
  final double phase;
  final double amplitude;
  final double frequency;
}

class TileParams {
  const TileParams(this.seed, this.tx, this.ty, this.minDist, this.tileSize,
      this.palette, this.minBrightness, this.maxBrightness, this.gamma);

  final int seed;
  final int tx;
  final int ty;
  final double minDist;
  final double tileSize;
  final List<int> palette;
  final int minBrightness;
  final int maxBrightness;
  final double gamma;
}

class StarfieldTileWorker {
  StarfieldTileWorker._() {
    if (!kIsWeb) {
      _receivePort = ReceivePort();
      _receivePort!.listen((message) {
        if (message is SendPort) {
          _sendPorts.add(message);
          if (_sendPorts.length == _poolSize) {
            _readyCompleter?.complete();
          }
          return;
        }
        if (message is List && message.length == 2) {
          final id = message[0] as int;
          final data = message[1] as List<StarData>;
          _pending.remove(id)?.complete(data);
        }
      });
    }
  }

  static final StarfieldTileWorker instance = StarfieldTileWorker._();

  static const int _poolSize = 2;

  ReceivePort? _receivePort;
  final List<SendPort> _sendPorts = [];
  final List<Isolate> _isolates = [];
  int _nextPort = 0;
  int _id = 0;
  final Map<int, Completer<List<StarData>>> _pending = {};
  Completer<void>? _readyCompleter;
  Future<void>? _starting;

  Future<void> _ensureStarted() {
    if (_sendPorts.length == _poolSize) {
      return Future.value();
    }
    return _starting ??= _start();
  }

  Future<void> _start() async {
    _readyCompleter = Completer<void>();
    for (var i = 0; i < _poolSize; i++) {
      final isolate =
          await Isolate.spawn(_tileWorkerMain, _receivePort!.sendPort);
      _isolates.add(isolate);
    }
    await _readyCompleter!.future;
    _readyCompleter = null;
    _starting = null;
  }

  Future<List<StarData>> run(TileParams params) async {
    if (kIsWeb) {
      return _generateTileStarData(params);
    }
    await _ensureStarted();
    final id = _id++;
    final completer = Completer<List<StarData>>();
    _pending[id] = completer;
    final port = _sendPorts[_nextPort];
    _nextPort = (_nextPort + 1) % _sendPorts.length;
    port.send([id, params]);
    return completer.future;
  }

  void dispose() {
    for (final isolate in _isolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    _isolates.clear();
    for (final c in _pending.values) {
      if (!c.isCompleted) {
        c.complete(const []);
      }
    }
    _pending.clear();
    _sendPorts.clear();
    _nextPort = 0;
    _receivePort?.close();
  }
}

@pragma('vm:entry-point')
void _tileWorkerMain(SendPort mainSendPort) {
  final port = ReceivePort();
  mainSendPort.send(port.sendPort);
  port.listen((message) {
    final id = message[0] as int;
    final params = message[1] as TileParams;
    final result = _generateTileStarData(params);
    mainSendPort.send([id, result]);
  });
}

Future<List<StarData>> runTileData(TileParams params) =>
    StarfieldTileWorker.instance.run(params);

List<Star> generateTileStars(TileParams params, double twinkleSpeed) {
  final raw = _generateTileStarData(params);
  return raw.map((d) => Star.fromData(d, twinkleSpeed)).toList(growable: false);
}

List<StarData> _generateTileStarData(TileParams params) {
  final seed = params.seed;
  final tx = params.tx;
  final ty = params.ty;
  final minDist = params.minDist;
  final tileSize = params.tileSize;
  if (minDist.isInfinite || minDist.isNaN) {
    return const <StarData>[];
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
            params.gamma,
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

StarData _randomStarData(Offset position, math.Random rnd, List<int> palette,
    int minBrightness, int maxBrightness, double gamma) {
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
  final t = math.pow(rnd.nextDouble(), gamma).toDouble();
  final brightness =
      (minBrightness + (maxBrightness - minBrightness) * t).round();
  final r = ((baseColor >> 16) & 0xFF) * brightness ~/ 255;
  final g = ((baseColor >> 8) & 0xFF) * brightness ~/ 255;
  final b = (baseColor & 0xFF) * brightness ~/ 255;
  final color = (r << 16) | (g << 8) | b;
  final phase = rnd.nextDouble() * math.pi * 2;
  final amplitude = 0.3 + rnd.nextDouble() * 0.2;
  final frequency = 0.8 + rnd.nextDouble() * 0.4;
  return StarData(
    position.dx,
    position.dy,
    radius,
    color,
    phase,
    amplitude,
    frequency,
  );
}

int _gridIndex(Offset p, double cellSize, int gridSize) =>
    (p.dx / cellSize).floor() + (p.dy / cellSize).floor() * gridSize;

class Star {
  Star(this.position, this.radius, this.colorTimeline, this.twinkleRate);

  static const int twinkleSamples = 64;
  static const int twinkleMask = twinkleSamples - 1;

  factory Star.fromData(StarData d, double twinkleSpeed) {
    final timeline = Int32List(twinkleSamples);
    final base = 1 - d.amplitude;
    for (var i = 0; i < twinkleSamples; i++) {
      final angle = (i / twinkleSamples) * 2 * math.pi + d.phase;
      final twinkle = math.sin(angle) * d.amplitude + base;
      timeline[i] = ((twinkle * 255).round() << 24) | d.color;
    }
    final rate = twinkleSpeed * d.frequency * twinkleSamples / (2 * math.pi);
    return Star(Offset(d.x, d.y), d.radius, timeline, rate);
  }

  final Offset position;
  final double radius;
  final Int32List colorTimeline;
  final double twinkleRate;
}
