import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final mergedStyle =
        _baseStyle.merge(style).copyWith(color: color ?? defaultColor);
    return AutoSizeText(
      data,
      maxLines: maxLines,
      textAlign: textAlign,
      style: mergedStyle,
    );
  }
}
