import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/ui/responsive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('responsiveIconSize', () {
    test('returns base size on phones', () {
      final constraints = BoxConstraints.tight(const Size(500, 800));
      expect(responsiveIconSize(constraints), 24);
    });

    test('doubles size on tablets', () {
      final constraints = BoxConstraints.tight(const Size(600, 800));
      expect(responsiveIconSize(constraints), 48);
    });

    test('triples size on desktops', () {
      final constraints = BoxConstraints.tight(const Size(900, 1200));
      expect(responsiveIconSize(constraints), 72);
    });

    test('honors custom base size', () {
      final constraints = BoxConstraints.tight(const Size(900, 1200));
      expect(responsiveIconSize(constraints, base: 30), 90);
    });
  });
}
