import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Provides global text scaling for [GameText] widgets.
class GameTextScale extends InheritedNotifier<ValueListenable<double>> {
  const GameTextScale({
    required ValueListenable<double> textScale,
    required super.child,
    super.key,
  }) : super(notifier: textScale);

  /// Returns the current scale factor from context, defaulting to `1` when
  /// no [GameTextScale] ancestor is found.
  static double of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<GameTextScale>();
    return inherited?.notifier?.value ?? 1;
  }
}

/// Displays text using a consistent style across game overlays.
///
/// Text is rendered without decoration and uses the game's primary colour by
/// default, but can be customised via [style], [maxLines] and [textAlign].
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

  static const _baseStyle = TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mergedStyle = _baseStyle.merge(style);
    final effectiveColor = color ?? mergedStyle.color ?? scheme.primary;
    final textStyle = mergedStyle.copyWith(
      color: effectiveColor,
      decoration: TextDecoration.none,
    );
    final baseSize = textStyle.fontSize ?? _baseStyle.fontSize!;
    final scale = GameTextScale.of(context);
    return AutoSizeText(
      data,
      maxLines: maxLines,
      textAlign: textAlign,
      style: textStyle.copyWith(fontSize: baseSize * scale),
    );
  }
}
