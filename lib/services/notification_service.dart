import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/errors/firebase_error_mapper.dart';
import '../core/helpers/app_logger.dart';

/// Wraps [FirebaseMessaging] — push notification permission, token, and
/// message-stream mechanics only.
///
/// Persisting a token against a user document, or turning an incoming
/// [RemoteMessage] into a Firestore `notifications` document, is
/// `NotificationRepository`'s job — this service doesn't know about
/// [NotificationModel] or Firestore at all, only about FCM.
class NotificationService {
  NotificationService([FirebaseMessaging? messaging])
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  /// Must be called once before any other method — prompts the user for
  /// notification permission (iOS/Android 13+) and returns whether it was
  /// granted.
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      throw FirebaseErrorMapper.mapMessagingError(e);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      throw FirebaseErrorMapper.mapMessagingError(e);
    }
  }

  /// Fires whenever the FCM token rotates (reinstall, token expiry, ...);
  /// callers should re-persist it against the current user each time.
  Stream<String> onTokenRefresh() => _messaging.onTokenRefresh;

  /// Messages received while the app is in the foreground. FCM does not
  /// auto-display a system notification in this case — the app decides
  /// what to do (Phase 3 UI concern).
  Stream<RemoteMessage> onForegroundMessage() => FirebaseMessaging.onMessage;

  /// Fires when the user taps a notification that opened/resumed the app
  /// from the background (not a cold start — see [getInitialMessage] for
  /// that case).
  Stream<RemoteMessage> onMessageOpenedApp() => FirebaseMessaging.onMessageOpenedApp;

  /// The message that launched the app from a fully terminated state, if
  /// any. Check this once at startup in addition to
  /// [onMessageOpenedApp].
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      throw FirebaseErrorMapper.mapMessagingError(e);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw FirebaseErrorMapper.mapMessagingError(e);
    }
  }
}

/// Background message handler.
///
/// Must be a top-level (or static) function per the `firebase_messaging`
/// contract, since it's invoked in a separate isolate when a data message
/// arrives while the app is terminated/backgrounded. Registered once in
/// `main.dart` via `FirebaseMessaging.onBackgroundMessage`.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Deliberately minimal: this isolate has no access to the app's normal
  // provider/service graph. Anything heavier (writing to Firestore,
  // updating local badge counts) is Phase 3's job once there's an actual
  // notification-handling UI to drive it.
  AppLogger.debug('Background FCM message received: ${message.messageId}');
}
