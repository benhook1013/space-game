import 'dart:math';

import 'package:flame/components.dart';

/// Simple spatial hash grid for efficient proximity queries.
class SpatialGrid<T extends PositionComponent> {
  SpatialGrid({required this.cellSize});

  /// Size of each grid cell in world coordinates.
  final double cellSize;

  final Map<Point<int>, Set<T>> _cells = {};

  Point<int> _cellFor(Vector2 position) => Point<int>(
      (position.x / cellSize).floor(), (position.y / cellSize).floor());

  /// Adds [component] to the grid.
  void add(T component) {
    final cell = _cellFor(component.position);
    _cells.putIfAbsent(cell, () => <T>{}).add(component);
  }

  /// Removes [component] from the grid.
  void remove(T component) {
    final cell = _cellFor(component.position);
    final set = _cells[cell];
    if (set == null) return;
    set.remove(component);
    if (set.isEmpty) {
      _cells.remove(cell);
    }
  }

  /// Updates the stored cell for [component] after movement.
  void update(T component, Vector2 previousPosition) {
    final oldCell = _cellFor(previousPosition);
    final newCell = _cellFor(component.position);
    if (oldCell == newCell) return;
    final oldSet = _cells[oldCell];
    if (oldSet != null) {
      oldSet.remove(component);
      if (oldSet.isEmpty) {
        _cells.remove(oldCell);
      }
    }
    _cells.putIfAbsent(newCell, () => <T>{}).add(component);
  }

  /// Returns all components within [radius] of [center].
  Iterable<T> query(Vector2 center, double radius) sync* {
    final min = _cellFor(center - Vector2.all(radius));
    final max = _cellFor(center + Vector2.all(radius));
    for (var x = min.x; x <= max.x; x++) {
      for (var y = min.y; y <= max.y; y++) {
        final set = _cells[Point<int>(x, y)];
        if (set != null) {
          for (final component in set) {
            yield component;
          }
        }
      }
    }
  }

  /// Removes all components from the grid.
  void clear() => _cells.clear();
}
