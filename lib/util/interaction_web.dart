// ignore_for_file: deprecated_member_use
import 'dart:html' as html;

void onFirstUserInteraction(void Function() callback) {
  var fired = false;
  void handler(html.Event _) {
    if (fired) return;
    fired = true;
    callback();
  }

  // Listen for desktop and mobile interactions.
  html.window.onMouseDown.first.then(handler);
  html.window.onTouchStart.first.then(handler);
}
