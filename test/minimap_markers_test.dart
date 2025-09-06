import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/enemy.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/minimap_display.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  @override
  Future<void> onLoad() async {}
}

class _TestEnemy extends EnemyComponent {
  @override
  Future<void> onLoad() async {}
}

Future<ui.Image> _paintToImage(CustomPainter painter, int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  painter.paint(canvas, Size(size.toDouble(), size.toDouble()));
  final picture = recorder.endRecording();
  return picture.toImage(size, size);
}

Future<int> _getPixel(ui.Image image, int x, int y) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final offset = (y * image.width + x) * 4;
  final r = data!.getUint8(offset);
  final g = data.getUint8(offset + 1);
  final b = data.getUint8(offset + 2);
  final a = data.getUint8(offset + 3);
  return Color.fromARGB(a, r, g, b).toARGB32();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('minimap shows and updates enemy markers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final keyDispatcher = KeyDispatcher();
    final joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    final player =
        _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    game.player = player;
    await game.add(player);

    final enemy = _TestEnemy()..position = Vector2(100, 0);
    await game.add(enemy);

    await tester.pumpWidget(MaterialApp(
      home: MiniMapDisplay(game: game, size: 100),
    ));
    await tester.pump();

    final painter = tester
        .widget<CustomPaint>(find.descendant(
            of: find.byType(MiniMapDisplay),
            matching: find.byType(CustomPaint)))
        .painter!;
    var image = await _paintToImage(painter, 100);
    var pixel = await _getPixel(image, 55, 50);
    expect(pixel, equals(Colors.redAccent.toARGB32()));

    enemy.position = Vector2(2000, 0);
    image = await _paintToImage(painter, 100);
    pixel = await _getPixel(image, 55, 50);
    expect(pixel, isNot(equals(Colors.redAccent.toARGB32())));
  }, skip: true);
}
