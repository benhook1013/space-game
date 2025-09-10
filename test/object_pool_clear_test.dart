import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/object_pool.dart';

void main() {
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
}
