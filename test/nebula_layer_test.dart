import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/components/nebula_layer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NebulaLayer', () {
    test('scales opacity with intensity and visibility', () {
      final layer = NebulaLayer(intensity: 0.5, parallax: 0.5);

      expect(layer.effectiveOpacity, closeTo(0.5, 0.0001));

      layer.setDebugVisibility(false);
      expect(layer.effectiveOpacity, 0);

      layer.setDebugVisibility(true);
      layer.opacity = 0.5;
      layer.setIntensity(0.8);

      expect(layer.effectiveOpacity, closeTo(0.4, 0.0001));
    });
  });
}
