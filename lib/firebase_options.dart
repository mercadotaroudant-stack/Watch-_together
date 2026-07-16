// File generated manually from the project's google-services.json
// (android/app/google-services.json), in the shape the FlutterFire CLI's
// `flutterfire configure` would normally produce.
//
// Only the Android platform is configured, per this project's scope
// (Android is the primary/only target). If iOS or web support is added
// later, re-run `flutterfire configure` to regenerate this file with
// those platforms included instead of hand-editing it further.
//
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Usage:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — this '
        'project only configures Android. Run `flutterfire configure` to '
        'add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS — this '
          'project only configures Android. Run `flutterfire configure` to '
          'add iOS support.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEJau9OFgsvQx1lsKwBp2RzuuUfYzYQlA',
    appId: '1:370078869544:android:1a52ab015fe527e5496d1d',
    messagingSenderId: '370078869544',
    projectId: 'watch-together-468f2',
    storageBucket: 'watch-together-468f2.firebasestorage.app',
  );
}
