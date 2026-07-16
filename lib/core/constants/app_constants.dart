/// Static, non-visual constants used across the app.
///
/// Anything visual (colors, spacing, radii) lives in `core/theme` instead —
/// this file is strictly for identity/config values.
abstract final class AppConstants {
  static const String appName = 'WatchTogether';
  static const String packageName = 'com.watchtogether.app';

  /// Shown on the About screen (drawer). A placeholder studio/team name
  /// rather than an individual's — update once the app has a public-
  /// facing developer/publisher name to display.
  static const String developerName = 'WatchTogether Team';

  /// Fallback shown while `PackageInfo.fromPlatform()` resolves (or if it
  /// fails) — kept in sync with `pubspec.yaml`'s `version:` by convention,
  /// not read from it at build time.
  static const String fallbackAppVersion = '1.0.0';

  /// Standard animation durations, kept consistent app-wide so motion feels
  /// intentional rather than ad-hoc per screen.
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Fixed delay before the splash screen navigates onward, regardless
  /// of how long its own intro animation takes.
  static const Duration splashNavigationDelay = Duration(milliseconds: 2500);

  /// Standard spacing scale (4pt grid), for use in `SizedBox`/`EdgeInsets`.
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  /// Standard corner radii.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
}
