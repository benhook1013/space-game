import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/components/starfield.dart';

void main() {
  test('starfield tile stars are sorted by radius', () {
    final starfield = StarfieldComponent();
    final radii = starfield.debugTileStarRadii(0, 0).toList();
    final sorted = List<double>.from(radii)..sort();
    expect(radii, sorted);
  });
}
