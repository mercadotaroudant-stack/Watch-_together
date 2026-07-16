import 'package:flutter/material.dart';

/// Shorthand accessors so widget code reads `context.textTheme` /
/// `context.colorScheme` instead of the more verbose
/// `Theme.of(context).textTheme`, etc.
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}

/// Shorthand for the current text direction, used by widgets that need to
/// branch on RTL (e.g. mirroring an icon) rather than relying purely on
/// directional widgets.
extension DirectionalityContext on BuildContext {
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
