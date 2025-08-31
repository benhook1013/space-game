import 'package:meta/meta.dart';

/// Generic object pool to minimise allocations by reusing instances.
class ObjectPool<T> {
  ObjectPool(this._create);

  final T Function() _create;
  final List<T> _items = [];

  /// Retrieves an instance from the pool, applying [reset] if provided.
  @visibleForTesting
  List<T> get items => _items;

  T acquire([void Function(T)? reset]) {
    final obj = _items.isNotEmpty ? _items.removeLast() : _create();
    reset?.call(obj);
    return obj;
  }

  /// Returns [obj] to the pool for future reuse.
  void release(T obj) => _items.add(obj);

  /// Clears all cached instances.
  void clear() => _items.clear();
}
