import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlayer {
  bool showRangeRings = false;
}

class _FakeGame {
  _FakeGame();

  final ValueNotifier<bool> showMinimap = ValueNotifier<bool>(false);
  final _FakePlayer player = _FakePlayer();

  void toggleMinimap() => showMinimap.value = !showMinimap.value;
  void toggleRangeRings() => player.showRangeRings = !player.showRangeRings;
}

void main() {
  testWidgets('buttons toggle minimap and range rings', (tester) async {
    final game = _FakeGame();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: game.toggleMinimap,
            ),
            IconButton(
              icon: const Icon(Icons.gps_fixed),
              onPressed: game.toggleRangeRings,
            ),
          ],
        ),
      ),
    ));

    expect(game.showMinimap.value, isFalse);
    await tester.tap(find.byIcon(Icons.map));
    await tester.pump();
    expect(game.showMinimap.value, isTrue);

    expect(game.player.showRangeRings, isFalse);
    await tester.tap(find.byIcon(Icons.gps_fixed));
    await tester.pump();
    expect(game.player.showRangeRings, isTrue);
  });
}
