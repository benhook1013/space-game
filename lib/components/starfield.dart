import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart' show ImageRepeat;

import '../constants.dart';

/// Persistent parallax starfield that caches its layers after the first build.
class StarfieldComponent extends ParallaxComponent<FlameGame> {
  StarfieldComponent() : super(priority: -1);

  static Parallax? _cachedParallax;

  @override
  Future<void> onLoad() async {
    parallax = _cachedParallax ??=
        await _buildParallax(Vector2.all(Constants.starfieldTileSize));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  // The starfield should behave like a distant background anchored in the
  // game world. Previously the component followed the camera, which caused the
  // stars to appear fixed to the player's ship. By letting the `Camera` handle
  // translation we allow the starfield to scroll naturally as the player moves
  // through space.

  // No explicit update override is needed; the component remains at world
  // coordinates and the camera movement provides the desired parallax effect.

  static Future<Parallax> _buildParallax(Vector2 size) async {
    final random = Random();
    final paint = Paint();

    Future<ParallaxImage> buildLayer() async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      for (var i = 0; i < Constants.starsPerLayer; i++) {
        final brightness = 128 + random.nextInt(128);
        paint.color = Color.fromARGB(255, brightness, brightness, brightness);
        final position = Offset(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        );
        final radius = random.nextDouble() * Constants.starMaxSize + 1;
        canvas.drawCircle(position, radius, paint);
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.x.toInt(), size.y.toInt());
      return ParallaxImage(image, repeat: ImageRepeat.repeat);
    }

    final slowLayer = ParallaxLayer(
      await buildLayer(),
      velocityMultiplier: Vector2.all(1),
    );
    final mediumLayer = ParallaxLayer(
      await buildLayer(),
      velocityMultiplier:
          Vector2.all(Constants.starSpeedMedium / Constants.starSpeedSlow),
    );
    final fastLayer = ParallaxLayer(
      await buildLayer(),
      velocityMultiplier:
          Vector2.all(Constants.starSpeedFast / Constants.starSpeedSlow),
    );

    return Parallax(
      [slowLayer, mediumLayer, fastLayer],
      baseVelocity: Vector2(0, Constants.starSpeedSlow),
    );
  }
}
