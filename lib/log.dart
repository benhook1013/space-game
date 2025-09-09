import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Logs [message] using [developer.log] so that output is available in all
/// builds. In debug/profile modes, the message is also printed using
/// [debugPrint] for convenience.
void log(
  String message, {
  String name = 'space_game',
  int level = 0,
  Object? error,
  StackTrace? stackTrace,
}) {
  developer.log(
    message,
    name: name,
    level: level,
    error: error,
    stackTrace: stackTrace,
  );
  if (!kReleaseMode) {
    debugPrint(message);
  }
}
