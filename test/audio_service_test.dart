import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:flame_audio/flame_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('master volume clamped between 0 and 1', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final service = await AudioService.create(storage);

    service.setMasterVolume(1.5);
    expect(service.masterVolume, 1);

    service.setMasterVolume(-0.5);
    expect(service.masterVolume, 0);
  });

  test('toggleMute flips flag and updates storage', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final service = await AudioService.create(storage);

    expect(service.muted.value, isFalse);
    expect(storage.isMuted(), isFalse);
    await service.toggleMute();
    expect(service.muted.value, isTrue);
    expect(storage.isMuted(), isTrue);
  });

  test('start/stop mining laser loop and mute prevents playback', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final player = _FakeAudioPlayer();
    final service = await _createLoopService(storage, player);

    await service.startMiningLaser();
    expect(service.miningLoop, isNotNull);

    service.stopMiningLaser();
    _expectLoopCleanedUp(player, service);

    await service.startMiningLaser();
    await service.toggleMute();
    _expectLoopCleanedUp(player, service);

    await service.startMiningLaser();
    expect(service.miningLoop, isNull);
  });

  test('master volume persists across sessions', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    var service = await AudioService.create(storage);
    service.setMasterVolume(0.3);

    service = await AudioService.create(storage);
    expect(service.masterVolume, closeTo(0.3, 1e-9));
  });

  test('muted state persists across sessions', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    var service = await AudioService.create(storage);
    expect(service.muted.value, isFalse);

    await service.toggleMute();
    expect(service.muted.value, isTrue);

    service = await AudioService.create(storage);
    expect(service.muted.value, isTrue);
  });

  _testLoopCleanup('stopAll halts active loops', (service) async {
    service.stopAll();
  });

  _testLoopCleanup('dispose stops loops and releases resources',
      (service) async {
    service.dispose();
  });
}

Future<AudioService> _createLoopService(
  StorageService storage,
  _FakeAudioPlayer player,
) async {
  return AudioService.create(
    storage,
    loop: (_, {double volume = 1}) async => player,
  );
}

void _expectLoopCleanedUp(_FakeAudioPlayer player, AudioService service) {
  expect(player.stopped, isTrue);
  expect(player.disposed, isTrue);
  expect(service.miningLoop, isNull);
}

void _testLoopCleanup(
  String description,
  Future<void> Function(AudioService) performTeardown,
) {
  test(description, () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final player = _FakeAudioPlayer();
    final service = await _createLoopService(storage, player);

    await service.startMiningLaser();
    expect(service.miningLoop, isNotNull);

    await performTeardown(service);
    _expectLoopCleanedUp(player, service);
  });
}

class _FakeAudioPlayer implements AudioPlayer {
  bool stopped = false;
  bool disposed = false;

  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
