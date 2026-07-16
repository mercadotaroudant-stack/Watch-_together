import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/helpers/app_logger.dart';

/// The app's real installed version string (e.g. `'1.0.0'`), read from
/// the platform via `package_info_plus` so it can never drift out of
/// sync with what was actually built — as a hardcoded string easily
/// would.
///
/// Falls back to [AppConstants.fallbackAppVersion] if the platform
/// channel call fails for any reason (e.g. running in an environment
/// without full platform support), so the splash screen always has
/// something to show rather than an error state for a non-critical
/// piece of UI.
final FutureProvider<String> appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version.isNotEmpty ? info.version : AppConstants.fallbackAppVersion;
  } catch (e) {
    AppLogger.warning(
      'Failed to read package info; falling back to default app version.',
      error: e,
    );
    return AppConstants.fallbackAppVersion;
  }
});
