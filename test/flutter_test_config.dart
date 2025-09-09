import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => '.';
}

Future<void> testExecutable(Future<void> Function() testMain) async {
  PathProviderPlatform.instance = _FakePathProviderPlatform();
  await testMain();
}
