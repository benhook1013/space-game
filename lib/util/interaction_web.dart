import 'dart:html' as html;

void onFirstUserInteraction(void Function() callback) {
  html.window.onPointerDown.first.then((_) => callback());
}
