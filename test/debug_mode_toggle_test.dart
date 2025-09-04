import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/components/enemy.dart';

class _HitboxGame extends SpaceGame {
  _HitboxGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  late final CircleHitbox hitbox;

  @override
  Future<void> onLoad() async {
    hitbox = CircleHitbox();
    final parent = PositionComponent();
    parent.add(hitbox);
    add(parent);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggleDebug switches debugMode', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    expect(game.debugMode, isTrue);
    game.toggleDebug();
    expect(game.debugMode, isFalse);
    game.toggleDebug();
    expect(game.debugMode, isTrue);
  });

  test('toggleDebug updates hitbox debugMode', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _HitboxGame(storage: storage, audio: audio);
    await game.onLoad();
    expect(game.hitbox.debugMode, isFalse);
    game.toggleDebug();
    expect(game.hitbox.debugMode, isFalse);
    game.toggleDebug();
    expect(game.hitbox.debugMode, isTrue);
    game.toggleDebug();
    expect(game.hitbox.debugMode, isFalse);
  });

  test('toggleDebug updates pooled component debugMode', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    final enemy = game.pools.acquire<EnemyComponent>((_) {});
    enemy.debugMode = true;
    game.pools.release(enemy);
    game.toggleDebug();
    final reused = game.pools.acquire<EnemyComponent>((_) {});
    expect(reused.debugMode, isFalse);
  });

  test('toggleDebug updates pooled child debugMode', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final enemy = game.pools.acquire<EnemyComponent>((_) {});
    enemy.game = game;
    await enemy.onLoad();
    final hitbox = enemy.children.query<CircleHitbox>().first;
    enemy.debugMode = true;
    hitbox.debugMode = true;
    game.pools.release(enemy);

    game.toggleDebug();
    final reused = game.pools.acquire<EnemyComponent>((_) {});
    final reusedHitbox = reused.children.query<CircleHitbox>().first;
    expect(reusedHitbox.debugMode, isFalse);
  });
}
