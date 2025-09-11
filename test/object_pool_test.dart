import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/object_pool.dart';

void main() {
  group('ObjectPool', () {
    test('clear discards cached instances', () {
      final discarded = <int>[];
      final pool = ObjectPool<int>(
        () => 0,
        onDiscard: discarded.add,
      );

      pool.release(1);
      pool.release(2);

      pool.clear();

      expect(discarded, [1, 2]);
      expect(pool.items, isEmpty);
    });

    test('respects maxSize when releasing', () {
      final pool = ObjectPool<int>(() => 0, maxSize: 1);
      pool.release(1);
      pool.release(2); // Should be discarded.

      expect(pool.items.length, 1);
      // Ensure the stored instance is the first one released.
      expect(pool.acquire(), 1);
    });

    test('fires onDiscard when pool is full', () {
      var discarded = 0;
      final pool = ObjectPool<int>(
        () => 0,
        maxSize: 1,
        onDiscard: (_) => discarded++,
      );

      pool.release(1);
      pool.release(2); // Triggers discard.

      expect(discarded, 1);
    });
  });
}
