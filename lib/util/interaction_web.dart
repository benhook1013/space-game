import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Invokes [callback] on the first user interaction and ensures it runs once.
///
/// The event listeners are removed before calling [callback] so a thrown
/// exception won't keep them around and accidentally fire the handler again.
void onFirstUserInteraction(void Function() callback) {
  var handled = false;

  late final web.EventListener listener;
  listener = ((web.Event _) {
    if (handled) {
      return;
    }
    handled = true;
    web.window.removeEventListener('pointerdown'.toJS as String, listener);
    web.window.removeEventListener('keydown'.toJS as String, listener);
    callback();
  }).toJS;

  web.window.addEventListener('pointerdown'.toJS as String, listener);
  web.window.addEventListener('keydown'.toJS as String, listener);
}
