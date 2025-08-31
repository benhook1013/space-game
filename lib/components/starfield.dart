import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart' show ImageRepeat;

import '../constants.dart';

/// Creates a parallax starfield using Flame's [ParallaxComponent].
///
/// The starfield consists of three layers that scroll at different
/// speeds to give a depth effect. Stars are drawn once into off-screen
/// images and the parallax system handles the scrolling and wrapping.
Future<ParallaxComponent> createStarfieldParallax(Vector2 size) async {
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

  final parallax = Parallax(
    [slowLayer, mediumLayer, fastLayer],
    baseVelocity: Vector2(0, Constants.starSpeedSlow),
  );
  return ParallaxComponent(parallax: parallax, priority: -1);
}
