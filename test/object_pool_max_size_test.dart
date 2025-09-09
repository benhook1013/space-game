import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/object_pool.dart';

void main() {
  test('pool respects maxSize when releasing', () {
    final pool = ObjectPool<int>(() => 0, maxSize: 1);
    pool.release(1);
    pool.release(2); // Should be discarded.

    expect(pool.items.length, 1);
    // Ensure the stored instance is the first one released.
    expect(pool.acquire(), 1);
  });

  test('onDiscard callback fires when pool is full', () {
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
}
