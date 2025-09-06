import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/enemy.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/components/mineral.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'test_images.dart';

Future<Color> _colorAt(CustomPainter painter, Size size, Offset point) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);
  painter.paint(canvas, size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ImageByteFormat.rawRgba);
  final index =
      ((point.dy.floor() * size.width.toInt()) + point.dx.floor()) * 4;
  final r = bytes!.getUint8(index);
  final g = bytes.getUint8(index + 1);
  final b = bytes.getUint8(index + 2);
  final a = bytes.getUint8(index + 3);
  return Color.fromARGB(a, r, g, b);
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    final keyDispatcher = KeyDispatcher();
    add(keyDispatcher);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = PlayerComponent(
      spritePath: Assets.players.first,
      joystick: joystick,
      keyDispatcher: keyDispatcher,
    )..position = Vector2.zero();
    await add(player);
    onGameResize(Vector2.all(200));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enemy marker appears and updates on minimap painter', () async {
    SharedPreferences.setMockInitialValues({});
    await loadTestImages([...Assets.players, ...Assets.enemies]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    final enemy = EnemyComponent()..reset(Vector2(100, 0));
    await game.add(enemy);

    const size = Size(80, 80);
    final painter = _TestMiniMapPainter(game);
    final initialColor = await _colorAt(painter, size, const Offset(45, 40));
    expect(initialColor.value, Colors.redAccent.value);

    enemy.position = Vector2(0, 100);
    final updatedColor = await _colorAt(painter, size, const Offset(40, 45));
    expect(updatedColor.value, Colors.redAccent.value);
  });
}

class _TestMiniMapPainter extends CustomPainter {
  _TestMiniMapPainter(this.game);

  final SpaceGame game;
  static const double _scale = 0.05;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final borderPaint = Paint()
      ..color = game.colorScheme.value.primary
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, borderPaint);

    final playerPaint = Paint()..color = game.colorScheme.value.primary;
    canvas.drawCircle(center, 3, playerPaint);

    final enemyPaint = Paint()..color = Colors.redAccent;
    final asteroidPaint = Paint()..color = Colors.grey;
    final mineralPaint = Paint()..color = Colors.amber;

    final playerPos = game.player.position;

    void drawDot(PositionComponent c, Paint paint) {
      final offset = (c.position - playerPos) * _scale;
      if (offset.length <= radius) {
        canvas.drawCircle(center + Offset(offset.x, offset.y), 2, paint);
      }
    }

    for (final enemy in game.children.whereType<EnemyComponent>()) {
      drawDot(enemy, enemyPaint);
    }
    for (final asteroid in game.children.whereType<AsteroidComponent>()) {
      drawDot(asteroid, asteroidPaint);
    }
    for (final mineral in game.children.whereType<MineralComponent>()) {
      drawDot(mineral, mineralPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TestMiniMapPainter oldDelegate) => true;
}
