import 'dart:collection';

import '../log.dart';

/// Generic object pool to minimise allocations by reusing instances.
class ObjectPool<T> {
  /// Creates a new pool that builds objects using [create].
  ///
  /// If [maxSize] is provided, the pool will keep at most that many
  /// instances when [release] is called. Additional releases are discarded
  /// to avoid unbounded memory growth.
  ObjectPool(
    T Function() create, {
    this.maxSize,
    this.onDiscard,
  }) : _create = create;

  final T Function() _create;
  final int? maxSize;
  final void Function(T obj)? onDiscard;
  final List<T> _items = [];
  late final UnmodifiableListView<T> _itemsView = UnmodifiableListView(_items);

  /// Returns an unmodifiable view of the cached items currently in the pool.
  ///
  /// Exposing the internal list directly would allow callers to modify it and
  /// break the pool's bookkeeping. The view is cached to avoid allocating a
  /// new wrapper on each access while still reflecting changes to the
  /// underlying list.
  UnmodifiableListView<T> get items => _itemsView;

  T acquire([void Function(T)? reset]) {
    final obj = _items.isNotEmpty ? _items.removeLast() : _create();
    reset?.call(obj);
    return obj;
  }

  /// Returns [obj] to the pool for future reuse.
  void release(T obj) {
    if (maxSize == null || _items.length < maxSize!) {
      _items.add(obj);
    } else {
      onDiscard?.call(obj);
      log(
        'ObjectPool discarding ${obj.runtimeType} as capacity '
        '${_items.length}/$maxSize is reached',
      );
    }
  }

  /// Clears all cached instances and calls [onDiscard] for each.
  ///
  /// This ensures pooled objects can release any resources before being
  /// dropped permanently, mirroring the behaviour when the pool reaches its
  /// [maxSize] in [release].
  void clear() {
    final discard = onDiscard;
    if (discard != null) {
      for (final item in _items) {
        discard(item);
      }
    }
    _items.clear();
  }
}
