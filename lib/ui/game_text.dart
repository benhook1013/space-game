import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Displays text using a consistent style across game overlays.
///
/// Defaults to yellow text with a modest font size but can be customised
/// via [style], [maxLines] and [textAlign].
class GameText extends StatelessWidget {
  const GameText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.color,
  });

  /// String to display.
  final String data;

  /// Additional style information merged with the base style.
  final TextStyle? style;

  /// Optional maximum number of lines the text should occupy.
  final int? maxLines;

  /// Alignment of the text within its bounds.
  final TextAlign? textAlign;

  /// Explicit colour override for the text.
  final Color? color;

  /// Base colour used for in-game text.
  static const Color defaultColor = Colors.yellow;

  static const _baseStyle = TextStyle(
    color: defaultColor,
    fontSize: 18,
  );

  /// Globally applied text scale factor. When attached, all [GameText]
  /// instances rebuild in response to changes.
  static ValueListenable<double>? textScale;

  /// Registers a [ValueListenable] that controls text scaling.
  static void attachTextScale(ValueListenable<double> notifier) {
    textScale = notifier;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildText(double scale) {
      final mergedStyle =
          _baseStyle.merge(style).copyWith(color: color ?? defaultColor);
      final baseSize = mergedStyle.fontSize ?? _baseStyle.fontSize!;
      return AutoSizeText(
        data,
        maxLines: maxLines,
        textAlign: textAlign,
        style: mergedStyle.copyWith(fontSize: baseSize * scale),
      );
    }

    final notifier = textScale;
    if (notifier != null) {
      return ValueListenableBuilder<double>(
        valueListenable: notifier,
        builder: (context, scale, _) => buildText(scale),
      );
    }
    return buildText(1);
  }
}
