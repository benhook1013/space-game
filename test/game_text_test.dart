import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/ui/game_text.dart';

void main() {
  testWidgets('GameText uses provided style color', (tester) async {
    const color = Colors.red;
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GameText(
          'test',
          style: TextStyle(color: color),
        ),
      ),
    ));

    final autoText = tester.widget<AutoSizeText>(find.byType(AutoSizeText));
    expect(autoText.style?.color, color);
  });
}
