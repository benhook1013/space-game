/// Utilities for responsive UI sizing.
///
/// Provides helpers to scale UI elements based on the current screen size so
/// the game feels consistent on phones, tablets and desktops.
import 'package:flutter/widgets.dart';

const double _desktopBreakpoint = 900;
const double _tabletBreakpoint = 600;

/// Extension on [BoxConstraints] providing responsive sizing helpers.
extension ResponsiveConstraints on BoxConstraints {
  /// Calculates an icon size that scales with the shortest side of this
  /// constraint.
  ///
  /// Returns a `24` point icon on small phones, `48` on tablets and `72` on
  /// larger desktop displays. Breakpoints roughly match Material layout
  /// guidelines.
  ///
  /// The returned size can be passed directly to [IconButton.iconSize].
  double responsiveIconSize({double base = 24}) {
    final shortestSide = biggest.shortestSide;
    if (shortestSide >= _desktopBreakpoint) {
      return base * 3; // Desktop.
    }
    if (shortestSide >= _tabletBreakpoint) {
      return base * 2; // Tablet.
    }
    return base; // Phone.
  }
}

/// Variant that operates on a [BuildContext].
extension ResponsiveContext on BuildContext {
  /// Calculates an icon size based on the current [MediaQuery] size.
  double responsiveIconSize({double base = 24}) {
    final constraints = BoxConstraints.tight(MediaQuery.of(this).size);
    return constraints.responsiveIconSize(base: base);
  }
}
