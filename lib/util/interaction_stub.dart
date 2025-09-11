import 'dart:async';

/// Immediately schedules [callback] to run asynchronously.
///
/// Matches the web implementation's behaviour by invoking the callback in a
/// microtask, ensuring consistent ordering and allowing exceptions to surface
/// through the event loop rather than synchronously.
void onFirstUserInteraction(void Function() callback) {
  Future.microtask(callback);
}
