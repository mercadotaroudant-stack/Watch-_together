import 'dart:async' show unawaited;
import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around `dart:developer`'s `log`, with an optional
/// Crashlytics sink for warnings/errors.
///
/// - The app never uses bare `print`/`debugPrint` (lint-enforced); this is
///   the one place logging happens, so swapping tools later means editing
///   one file.
/// - [isEnabled] is the single switch to silence all console/`developer.log`
///   output (e.g. flipped off via `AppLogger.isEnabled = false`) without
///   touching call sites throughout the app. It defaults to [kDebugMode]
///   so release builds are quiet out of the box.
/// - Crashlytics recording (in [warning]/[error], on by default) is
///   independent of [isEnabled]: crash reports should still reach
///   Crashlytics in release builds even though nothing is printed to the
///   console.
abstract final class AppLogger {
  static bool isEnabled = kDebugMode;

  static void debug(String message, {String name = 'WatchTogether'}) {
    if (!isEnabled) return;
    developer.log(message, name: name, level: 500);
  }

  static void info(String message, {String name = 'WatchTogether'}) {
    if (!isEnabled) return;
    developer.log(message, name: name, level: 800);
  }

  static void warning(
    String message, {
    String name = 'WatchTogether',
    Object? error,
    bool recordToCrashlytics = true,
  }) {
    if (isEnabled) {
      developer.log(message, name: name, level: 900, error: error);
    }
    if (recordToCrashlytics && !kDebugMode) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error ?? message,
          null,
          reason: message,
          fatal: false,
        ),
      );
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'WatchTogether',
    bool recordToCrashlytics = true,
    bool fatal = false,
  }) {
    if (isEnabled) {
      developer.log(
        message,
        name: name,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (recordToCrashlytics && !kDebugMode) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error ?? message,
          stackTrace,
          reason: message,
          fatal: fatal,
        ),
      );
    }
  }
}
