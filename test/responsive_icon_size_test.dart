import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/ui/responsive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResponsiveConstraints', () {
    test('returns base size on phones', () {
      final constraints = BoxConstraints.tight(const Size(500, 800));
      expect(constraints.responsiveIconSize(), 24);
    });

    test('doubles size on tablets', () {
      final constraints = BoxConstraints.tight(const Size(600, 800));
      expect(constraints.responsiveIconSize(), 48);
    });

    test('triples size on desktops', () {
      final constraints = BoxConstraints.tight(const Size(900, 1200));
      expect(constraints.responsiveIconSize(), 72);
    });

    test('honors custom base size', () {
      final constraints = BoxConstraints.tight(const Size(900, 1200));
      expect(constraints.responsiveIconSize(base: 30), 90);
    });
  });
}
