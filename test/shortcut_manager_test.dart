import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:space_game/game/game_state.dart';
import 'package:space_game/game/game_state_machine.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/shortcut_manager.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/overlay_service.dart';

class _FakeOverlayService implements OverlayService {
  @override
  final Game game = FlameGame();

  @override
  void showHud() {}
  @override
  void showPause() {}
  @override
  void showGameOver() {}
  @override
  void showMenu() {}

  @override
  void showHelp() {}
  @override
  void hideHelp() {}
  @override
  void showUpgrades() {}
  @override
  void hideUpgrades() {}
  @override
  void showSettings() {}
  @override
  void hideSettings() {}
}

class _FakeAudioService implements AudioService {
  bool toggled = false;

  @override
  final ValueNotifier<bool> muted = ValueNotifier(false);
  double _volume = 1;

  @override
  double get masterVolume => _volume;

  @override
  void setMasterVolume(double volume) {
    _volume = volume;
  }

  @override
  Future<void> toggleMute() async {
    toggled = true;
  }

  @override
  void playShoot() {}

  @override
  void playExplosion() {}

  @override
  Future<void> startMiningLaser() async {}

  @override
  void stopMiningLaser() {}

  @override
  void stopAll() {}

  @override
  AudioPlayer? get miningLoop => null;
}

class _Harness {
  _Harness() {
    stateMachine = GameStateMachine(
      overlays: _FakeOverlayService(),
      onStart: () {},
      onPause: () {},
      onResume: () {},
      onGameOver: () {},
      onMenu: () {},
    );
    ShortcutManager(
      keyDispatcher: dispatcher,
      stateMachine: stateMachine,
      audioService: audio,
      pauseGame: () => pauseCalled = true,
      resumeGame: () => resumeCalled = true,
      startGame: () => startCalled = true,
      toggleHelp: () => helpCalled = true,
      toggleUpgrades: () => upgradesCalled = true,
      toggleDebug: () => debugCalled = true,
      toggleMinimap: () => minimapCalled = true,
      toggleRangeRings: () => rangeRingsCalled = true,
      returnToMenu: () => menuCalled = true,
      isHelpVisible: () => helpVisible,
    );
  }

  final dispatcher = KeyDispatcher();
  late final GameStateMachine stateMachine;
  final _FakeAudioService audio = _FakeAudioService();
  bool pauseCalled = false;
  bool resumeCalled = false;
  bool startCalled = false;
  bool helpCalled = false;
  bool upgradesCalled = false;
  bool debugCalled = false;
  bool minimapCalled = false;
  bool rangeRingsCalled = false;
  bool menuCalled = false;
  bool helpVisible = false;

  void press(LogicalKeyboardKey logical, PhysicalKeyboardKey physical) {
    dispatcher.onKeyEvent(
      KeyDownEvent(
        logicalKey: logical,
        physicalKey: physical,
        timeStamp: Duration.zero,
      ),
      {logical},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShortcutManager', () {
    test('escape pauses and resumes based on state', () {
      final h = _Harness()..stateMachine.state = GameState.playing;

      h.press(LogicalKeyboardKey.escape, PhysicalKeyboardKey.escape);
      expect(h.pauseCalled, isTrue);

      h.pauseCalled = false;
      h.stateMachine.state = GameState.paused;
      h.press(LogicalKeyboardKey.escape, PhysicalKeyboardKey.escape);
      expect(h.resumeCalled, isTrue);
      expect(h.pauseCalled, isFalse);
    });

    test('escape hides help when visible', () {
      final h = _Harness()..stateMachine.state = GameState.playing;
      h.helpVisible = true;

      h.press(LogicalKeyboardKey.escape, PhysicalKeyboardKey.escape);
      expect(h.helpCalled, isTrue);
      expect(h.pauseCalled, isFalse);
    });

    test('P key mirrors escape for pause/resume', () {
      final h = _Harness()..stateMachine.state = GameState.playing;

      h.press(LogicalKeyboardKey.keyP, PhysicalKeyboardKey.keyP);
      expect(h.pauseCalled, isTrue);

      h.pauseCalled = false;
      h.stateMachine.state = GameState.paused;
      h.press(LogicalKeyboardKey.keyP, PhysicalKeyboardKey.keyP);
      expect(h.resumeCalled, isTrue);
      expect(h.pauseCalled, isFalse);
    });

    test('M toggles mute', () {
      final h = _Harness();
      h.press(LogicalKeyboardKey.keyM, PhysicalKeyboardKey.keyM);
      expect(h.audio.toggled, isTrue);
    });

    test('Enter starts game from menu and game over', () {
      final h = _Harness()..stateMachine.state = GameState.menu;

      h.press(LogicalKeyboardKey.enter, PhysicalKeyboardKey.enter);
      expect(h.startCalled, isTrue);

      h.startCalled = false;
      h.stateMachine.state = GameState.gameOver;
      h.press(LogicalKeyboardKey.enter, PhysicalKeyboardKey.enter);
      expect(h.startCalled, isTrue);
    });

    test('R restarts game from playing, paused, and game over', () {
      final h = _Harness()..stateMachine.state = GameState.playing;

      h.press(LogicalKeyboardKey.keyR, PhysicalKeyboardKey.keyR);
      expect(h.startCalled, isTrue);

      h.startCalled = false;
      h.stateMachine.state = GameState.paused;
      h.press(LogicalKeyboardKey.keyR, PhysicalKeyboardKey.keyR);
      expect(h.startCalled, isTrue);

      h.startCalled = false;
      h.stateMachine.state = GameState.gameOver;
      h.press(LogicalKeyboardKey.keyR, PhysicalKeyboardKey.keyR);
      expect(h.startCalled, isTrue);
    });

    test('H toggles help', () {
      final h = _Harness();
      h.press(LogicalKeyboardKey.keyH, PhysicalKeyboardKey.keyH);
      expect(h.helpCalled, isTrue);
    });

    test('U toggles upgrades', () {
      final h = _Harness();
      h.press(LogicalKeyboardKey.keyU, PhysicalKeyboardKey.keyU);
      expect(h.upgradesCalled, isTrue);
    });

    test('F1 toggles debug', () {
      final h = _Harness();
      h.press(LogicalKeyboardKey.f1, PhysicalKeyboardKey.f1);
      expect(h.debugCalled, isTrue);
    });

    test('N toggles minimap', () {
      final h = _Harness();
      h.press(LogicalKeyboardKey.keyN, PhysicalKeyboardKey.keyN);
      expect(h.minimapCalled, isTrue);
    });

    test('B toggles range rings', () {
      final h = _Harness();
      h.press(LogicalKeyboardKey.keyB, PhysicalKeyboardKey.keyB);
      expect(h.rangeRingsCalled, isTrue);
    });

    test('Q returns to menu from pause or game over', () {
      final h = _Harness()..stateMachine.state = GameState.paused;
      h.press(LogicalKeyboardKey.keyQ, PhysicalKeyboardKey.keyQ);
      expect(h.menuCalled, isTrue);

      h.menuCalled = false;
      h.stateMachine.state = GameState.gameOver;
      h.press(LogicalKeyboardKey.keyQ, PhysicalKeyboardKey.keyQ);
      expect(h.menuCalled, isTrue);
    });
  });
}
