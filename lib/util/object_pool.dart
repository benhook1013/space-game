import 'dart:collection';

/// Generic object pool to minimise allocations by reusing instances.
class ObjectPool<T> {
  /// Creates a new pool that builds objects using [create].
  ///
  /// If [maxSize] is provided, the pool will keep at most that many
  /// instances when [release] is called. Additional releases are discarded
  /// to avoid unbounded memory growth.
  ObjectPool(T Function() create, {this.maxSize}) : _create = create;

  final T Function() _create;
  final int? maxSize;
  final List<T> _items = [];

  /// Returns an unmodifiable view of the cached items currently in the pool.
  ///
  /// Exposing the internal list directly would allow callers to modify it and
  /// break the pool's bookkeeping. Returning an [UnmodifiableListView] keeps
  /// the data read-only while still reflecting updates to the underlying list
  /// without additional copying.
  UnmodifiableListView<T> get items => UnmodifiableListView(_items);

  T acquire([void Function(T)? reset]) {
    final obj = _items.isNotEmpty ? _items.removeLast() : _create();
    reset?.call(obj);
    return obj;
  }

  /// Returns [obj] to the pool for future reuse.
  void release(T obj) {
    if (maxSize == null || _items.length < maxSize!) {
      _items.add(obj);
    }
  }

  /// Clears all cached instances.
  void clear() => _items.clear();
}
