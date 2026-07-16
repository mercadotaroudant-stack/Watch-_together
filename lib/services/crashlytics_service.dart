import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around [FirebaseCrashlytics].
///
/// `AppLogger.error`/`warning` already forward to this for ad-hoc
/// logging (see `core/helpers/app_logger.dart`); this service is for the
/// global hooks wired once in `main.dart` (uncaught Flutter/platform
/// errors) and for attaching user context.
class CrashlyticsService {
  CrashlyticsService([FirebaseCrashlytics? crashlytics])
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  /// Wires Crashlytics to catch every uncaught Flutter framework error
  /// and every uncaught platform-level error. Call once from
  /// `main.dart` before `runApp`.
  Future<void> initialize() async {
    // Crashlytics collection is only useful in release builds; keeping it
    // off in debug avoids noisy reports from hot-reload/dev exceptions.
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = _crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<void> setUserId(String? uid) => _crashlytics.setUserIdentifier(uid ?? '');

  Future<void> log(String message) => _crashlytics.log(message);

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) =>
      _crashlytics.recordError(error, stackTrace, reason: reason, fatal: fatal);
}
