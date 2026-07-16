/// Central registry of asset paths.
///
/// Referencing `AssetPaths.logo.primary` instead of a raw string means a
/// typo becomes a compile-time-visible constant lookup instead of a
/// silently-missing image at runtime, and a renamed/moved file only needs
/// updating in one place.
///
/// Folders are declared and asset-mapped in pubspec.yaml even though no
/// individual files ship yet in Phase 1 — add the actual files under
/// assets/<folder>/ and reference them here as they're introduced.
abstract final class AssetPaths {
  static const String _logo = 'assets/logo';
  static const String _icons = 'assets/icons';
  static const String _illustrations = 'assets/illustrations';
  static const String _animations = 'assets/animations';
  static const String _images = 'assets/images';

  // Example usage once real files exist:
  // static const String emptyStateIllustration = '$_illustrations/empty_state.svg';

  /// Official app logo. Source: see assets/logo/README.md for the
  /// original URL and download instructions — the file itself isn't
  /// bundled yet because this project was built without network access.
  /// Used later (Phase 3+) for auth screens, the drawer header, and the
  /// about screen; already used by the `flutter_launcher_icons` /
  /// `flutter_native_splash` config in pubspec.yaml for the app icon and
  /// native splash screen.
  static const String appLogo = '$_logo/app_logo.png';

  /// Default thumbnail for a room/video with no saved background image
  /// (Watch History, Phase 3.10, and anywhere else a room poster is
  /// shown). Like [appLogo], the path is declared here even though the
  /// file itself isn't bundled yet — every place that renders it treats
  /// a load failure as "use the in-code gradient fallback", never as a
  /// random/external image.
  static const String videoPlaceholder = '$_images/video_placeholder.png';

  static const String logoDir = _logo;
  static const String iconsDir = _icons;
  static const String illustrationsDir = _illustrations;
  static const String animationsDir = _animations;
  static const String imagesDir = _images;
}
