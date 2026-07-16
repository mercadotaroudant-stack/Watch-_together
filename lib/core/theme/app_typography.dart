import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// WatchTogether's typography scale.
///
/// Built on Material 3's type roles (display / headline / title / body /
/// label, each in large / medium / small) using Poppins as the single
/// brand typeface. Centralizing this means screens should reach for
/// `Theme.of(context).textTheme.*` instead of constructing `TextStyle`s
/// inline, keeping type usage consistent app-wide.
abstract final class AppTypography {
  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme(_base).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );

  static const TextTheme _base = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w600, height: 1.12),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w600, height: 1.16),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, height: 1.22),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, height: 1.25),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.29),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.27),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.43),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45),
  );
}
