import 'package:flutter/foundation.dart';

/// Simple wrapper around [debugPrint] to allow easy silencing in release builds.
void log(String message) {
  if (!kReleaseMode) {
    debugPrint(message);
  }
}
