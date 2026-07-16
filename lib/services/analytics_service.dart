import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin wrapper around [FirebaseAnalytics].
///
/// Every call site logs through named methods here (`logSignUp`,
/// `logRoomCreated`, ...) rather than calling `logEvent` directly
/// throughout the app, so event names/parameter keys are defined in
/// exactly one place and can't drift between call sites.
class AnalyticsService {
  AnalyticsService([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get navigatorObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> setUserId(String? uid) => _analytics.setUserId(id: uid);

  Future<void> setUserProperty({required String name, required String? value}) =>
      _analytics.setUserProperty(name: name, value: value);

  Future<void> logSignUp({required String method}) =>
      _analytics.logSignUp(signUpMethod: method);

  Future<void> logLogin({required String method}) =>
      _analytics.logLogin(loginMethod: method);

  Future<void> logLogout() => _analytics.logEvent(name: 'logout');

  Future<void> logRoomCreated({required String roomId, required bool isPrivate}) =>
      _analytics.logEvent(
        name: 'room_created',
        parameters: {'room_id': roomId, 'is_private': isPrivate},
      );

  Future<void> logRoomJoined({required String roomId}) =>
      _analytics.logEvent(name: 'room_joined', parameters: {'room_id': roomId});

  Future<void> logRoomLeft({required String roomId}) =>
      _analytics.logEvent(name: 'room_left', parameters: {'room_id': roomId});

  Future<void> logFriendRequestSent() =>
      _analytics.logEvent(name: 'friend_request_sent');

  Future<void> logScreenView({required String screenName}) =>
      _analytics.logScreenView(screenName: screenName);

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);
}
