import 'dart:ui';

import 'package:flame/flame.dart';

/// Registers 1×1 placeholder images for the given asset [paths].
///
/// Loading real sprites is unnecessary in most unit tests and can make them
/// brittle when asset files or the Flutter asset bundle are unavailable. This
/// helper inserts a tiny blank image into [Flame.images] for each path so tests
/// can instantiate components without touching the filesystem.
Future<void> loadTestImages(Iterable<String> paths) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint());
  final image = await recorder.endRecording().toImage(1, 1);
  for (final path in paths) {
    Flame.images.add(path, image);
  }
}
