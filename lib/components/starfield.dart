import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../constants.dart';
import '../game/space_game.dart';

/// Procedural parallax starfield rendered behind the gameplay.
class StarfieldComponent extends Component with HasGameReference<SpaceGame> {
  StarfieldComponent({int starsPerLayer = Constants.starsPerLayer})
      : _starsPerLayer = starsPerLayer,
        super(priority: -1);

  final int _starsPerLayer;
  final Random _random = Random();
  final List<_Star> _stars = [];
  final Paint _paint = Paint();

  @override
  Future<void> onLoad() async {
    if (!game.size.isZero()) {
      _initStars();
    }
  }

  void _initStars() {
    _stars
      ..clear()
      ..addAll(_generateLayer(Constants.starSpeedSlow))
      ..addAll(_generateLayer(Constants.starSpeedMedium))
      ..addAll(_generateLayer(Constants.starSpeedFast));
  }

  List<_Star> _generateLayer(double speed) {
    return List.generate(_starsPerLayer, (_) {
      final brightness = 128 + _random.nextInt(128);
      return _Star(
        position: Vector2(
          _random.nextDouble() * game.size.x,
          _random.nextDouble() * game.size.y,
        ),
        speed: speed,
        radius: _random.nextDouble() * Constants.starMaxSize + 1,
        color: Color.fromARGB(255, brightness, brightness, brightness),
      );
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _initStars();
  }

  @override
  void update(double dt) {
    for (final star in _stars) {
      star.position.y += star.speed * dt;
      if (star.position.y > game.size.y) {
        star.position
          ..y = 0
          ..x = _random.nextDouble() * game.size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    for (final star in _stars) {
      _paint.color = star.color;
      canvas.drawCircle(star.position.toOffset(), star.radius, _paint);
    }
  }
}

class _Star {
  _Star({
    required this.position,
    required this.speed,
    required this.radius,
    required this.color,
  });

  Vector2 position;
  double speed;
  double radius;
  Color color;
}
