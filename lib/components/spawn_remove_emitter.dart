import 'package:flame/components.dart';

import '../game/event_bus.dart';
import '../game/space_game.dart';

/// Mixin that emits spawn and remove events to the game's [GameEventBus].
///
/// When a component is mounted or removed, corresponding [ComponentSpawnEvent]
/// and [ComponentRemoveEvent] events are fired. This centralises event bus
/// wiring for pooled components.
mixin SpawnRemoveEmitter<T extends Component>
    on Component, HasGameReference<SpaceGame> {
  @override
  void onMount() {
    super.onMount();
    game.eventBus.emit(ComponentSpawnEvent<T>(this as T));
  }

  @override
  void onRemove() {
    super.onRemove();
    game.eventBus.emit(ComponentRemoveEvent<T>(this as T));
  }
}
