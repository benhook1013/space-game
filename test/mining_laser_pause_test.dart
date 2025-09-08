import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/mining_laser.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';

class _TestMiningLaser extends MiningLaserComponent {
  _TestMiningLaser({required super.player});

  bool stopped = false;

  @override
  void stopSound() {
    stopped = true;
    super.stopSound();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Escape key lowers volume when paused', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    audio.muted.value = true;
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(100));
    await game.startGame();
    await game.ready();

    final laser = _TestMiningLaser(player: game.player);
    game.miningLaser?.removeFromParent();
    game.miningLaser = laser;
    await game.add(laser);
    await game.ready();

    const down = KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.escape,
      logicalKey: LogicalKeyboardKey.escape,
      timeStamp: Duration.zero,
    );
    const up = KeyUpEvent(
      physicalKey: PhysicalKeyboardKey.escape,
      logicalKey: LogicalKeyboardKey.escape,
      timeStamp: Duration.zero,
    );
    game.keyDispatcher.onKeyEvent(down, {});
    game.keyDispatcher.onKeyEvent(up, {});

    expect(laser.stopped, isFalse);
    expect(audio.masterVolume, Constants.pausedAudioVolumeFactor);

    game.keyDispatcher.onKeyEvent(down, {});
    game.keyDispatcher.onKeyEvent(up, {});
    expect(audio.masterVolume, 1);
  });

  test('Restart key restores volume after pause', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    audio.muted.value = true;
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(100));
    await game.startGame();
    await game.ready();

    const escDown = KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.escape,
      logicalKey: LogicalKeyboardKey.escape,
      timeStamp: Duration.zero,
    );
    const escUp = KeyUpEvent(
      physicalKey: PhysicalKeyboardKey.escape,
      logicalKey: LogicalKeyboardKey.escape,
      timeStamp: Duration.zero,
    );
    game.keyDispatcher.onKeyEvent(escDown, {});
    game.keyDispatcher.onKeyEvent(escUp, {});
    expect(audio.masterVolume, Constants.pausedAudioVolumeFactor);

    const rDown = KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.keyR,
      logicalKey: LogicalKeyboardKey.keyR,
      timeStamp: Duration.zero,
    );
    const rUp = KeyUpEvent(
      physicalKey: PhysicalKeyboardKey.keyR,
      logicalKey: LogicalKeyboardKey.keyR,
      timeStamp: Duration.zero,
    );
    game.keyDispatcher.onKeyEvent(rDown, {});
    game.keyDispatcher.onKeyEvent(rUp, {});
    await game.ready();
    expect(audio.masterVolume, 1);
  });
}
