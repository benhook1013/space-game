import 'dart:html' as html; // ignore: deprecated_member_use

void onFirstUserInteraction(void Function() callback) {
  void handler(html.Event _) {
    callback();
    html.window.removeEventListener('pointerdown', handler);
    html.window.removeEventListener('keydown', handler);
  }

  html.window.addEventListener('pointerdown', handler);
  html.window.addEventListener('keydown', handler);
}
