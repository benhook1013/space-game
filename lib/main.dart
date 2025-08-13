import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'game/space_game.dart';

/// Application entry point.
void main() {
  final game = SpaceGame();
  runApp(GameWidget(game: game));
}
