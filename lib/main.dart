import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/helpers/app_logger.dart';
import 'firebase_options.dart';
import 'providers/storage_service_provider.dart';
import 'services/crashlytics_service.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'services/remote_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Firebase bootstrap ---
  //
  // Order matters: Crashlytics needs Firebase.initializeApp() to have
  // run first; the background FCM handler must be registered before any
  // message can arrive; Remote Config's first fetch is awaited so the
  // app never briefly runs with stale/no config on a cold start.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final CrashlyticsService crashlyticsService = CrashlyticsService();
  await crashlyticsService.initialize();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final RemoteConfigService remoteConfigService = RemoteConfigService();
  await remoteConfigService.initialize();

  // Resolve every other async dependency the provider tree needs
  // *before* runApp, then hand it to Riverpod via `overrides`. This
  // keeps every provider in the app synchronous and side-effect-free to
  // read.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  AppLogger.info('WatchTogether backend initialized (Firebase, Remote Config, Crashlytics).');

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
      ],
      child: const WatchTogetherApp(),
    ),
  );
}
