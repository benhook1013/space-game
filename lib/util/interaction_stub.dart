import 'dart:async';

/// Invokes [callback] asynchronously on the next microtask.
///
/// This mirrors the web implementation where callbacks are triggered by event
/// listeners, ensuring consistent error handling and invocation order across
/// platforms.
void onFirstUserInteraction(void Function() callback) {
  scheduleMicrotask(callback);
}
