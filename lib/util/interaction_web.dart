import 'dart:html' as html; // ignore: deprecated_member_use

/// Invokes [callback] on the first user interaction and ensures it runs once.
///
/// The event listeners are removed before calling [callback] so a thrown
/// exception won't keep them around and accidentally fire the handler again.
void onFirstUserInteraction(void Function() callback) {
  var handled = false;

  void handler(html.Event _) {
    if (handled) {
      return;
    }
    handled = true;
    html.window.removeEventListener('pointerdown', handler);
    html.window.removeEventListener('keydown', handler);
    callback();
  }

  html.window.addEventListener('pointerdown', handler);
  html.window.addEventListener('keydown', handler);
}
