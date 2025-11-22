import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/object_pool.dart';

void main() {
  group('ObjectPool', () {
    test('invokes discard callback for full pools and clearing', () {
      final discarded = <int>[];
      final pool = ObjectPool<int>(
        () => 0,
        maxSize: 1,
        onDiscard: discarded.add,
      );

      pool.release(1);
      pool.release(2); // Discarded because the pool is full.
      pool.clear(); // Discards the cached instance.

      expect(discarded, [2, 1]);
      expect(pool.items, isEmpty);
    });
  });
}
