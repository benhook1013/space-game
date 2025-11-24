import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'starfield_cache.dart';
import 'starfield_config.dart';
import 'starfield_worker.dart';

class StarfieldRenderer {
  StarfieldRenderer(this.starImage);

  final Image starImage;

  void render(
    Canvas canvas,
    List<LayerState> layers,
    Vector2 Function(StarfieldLayerConfig config) cameraForLayer,
    Vector2 viewSize,
    double tileSize,
    double time,
    Paint starPaint,
    Paint outlinePaint,
    bool debugDrawTiles,
  ) {
    for (final layer in layers) {
      final cfg = layer.config;
      final cameraPos = cameraForLayer(cfg);
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
          touch(layer, key);
          final offsetX = tx * tileSize;
          final offsetY = ty * tileSize;
          canvas.save();
          canvas.translate(offsetX, offsetY);
          for (var i = 0; i < tile.stars.length; i++) {
            final star = tile.stars[i];
            final idx = (time * star.twinkleRate).toInt() & Star.twinkleMask;
            tile.colors[i] = star.colorTimeline[idx];
          }
          canvas.drawRawAtlas(
            starImage,
            tile.transforms,
            tile.rects,
            tile.colors,
            BlendMode.srcOver,
            null,
            starPaint,
          );
          if (debugDrawTiles) {
            canvas.drawRect(
              Rect.fromLTWH(
                0,
                0,
                tileSize,
                tileSize,
              ),
              outlinePaint,
            );
          }
          canvas.restore();
        }
      }
      canvas.restore();
    }
  }
}
