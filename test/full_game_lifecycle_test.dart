import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';

class _FakeAudioCache extends AudioCache {
  @override
  Future<Uri> load(String file) async => Uri();

  @override
  Future<void> clearAll() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('asset loaders can be called multiple times and missing asset throws',
      () async {
    Flame.images.clearCache();
    FlameAudio.audioCache = _FakeAudioCache();

    await Assets.loadEssential();
    await Assets.loadEssential();
    await Assets.loadRemaining();
    await Assets.loadRemaining();

    expect(
      () => Flame.images.fromCache('does_not_exist.png'),
      throwsA(isA<AssertionError>()),
    );
  });

  test('full lifecycle with scoring and persistence across restarts', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players, ...Assets.explosions]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(200));

    expect(game.stateMachine.state, GameState.menu);
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);

    // First run.
    await game.startGame();
    expect(game.stateMachine.state, GameState.playing);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);

    // Score some points and purchase an upgrade.
    const scoreValue = 42;
    final upgrade = game.upgradeService.upgrades.first;
    game.addScore(scoreValue);
    game.addMinerals(upgrade.cost);
    expect(game.upgradeService.buy(upgrade), isTrue);

    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      game.hitPlayer();
    }
    expect(game.stateMachine.state, GameState.gameOver);
    expect(game.overlays.isActive(GameOverOverlay.id), isTrue);

    game.returnToMenu();
    expect(game.stateMachine.state, GameState.menu);
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);
    expect(game.overlays.isActive(GameOverOverlay.id), isFalse);
    expect(game.overlays.isActive(HudOverlay.id), isFalse);

    // Second run should reset score but preserve high score and upgrades.
    await game.startGame();
    expect(game.stateMachine.state, GameState.playing);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
    expect(game.scoreService.score.value, 0);
    expect(game.scoreService.highScore.value, scoreValue);
    expect(game.upgradeService.isPurchased(upgrade.id), isTrue);

    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      game.hitPlayer();
    }
    expect(game.stateMachine.state, GameState.gameOver);
    expect(game.overlays.isActive(GameOverOverlay.id), isTrue);

    game.returnToMenu();
    expect(game.stateMachine.state, GameState.menu);
    expect(game.overlays.isActive(MenuOverlay.id), isTrue);
    expect(game.overlays.isActive(GameOverOverlay.id), isFalse);

    // Third run to verify overlays after multiple restarts.
    await game.startGame();
    expect(game.stateMachine.state, GameState.playing);
    expect(game.overlays.isActive(HudOverlay.id), isTrue);
    expect(game.scoreService.score.value, 0);
    expect(game.scoreService.highScore.value, scoreValue);
    expect(game.upgradeService.isPurchased(upgrade.id), isTrue);
  });
}
