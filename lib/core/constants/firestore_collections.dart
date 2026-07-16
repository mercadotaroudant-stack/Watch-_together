/// Central registry of every Firestore collection name.
///
/// Referencing `FirestoreCollections.rooms` instead of the literal string
/// `'rooms'` means a typo is a compile error, and renaming a collection
/// only requires updating one place.
abstract final class FirestoreCollections {
  static const String users = 'users';
  static const String rooms = 'rooms';
  static const String participants = 'participants';
  static const String messages = 'messages';
  static const String friends = 'friends';
  static const String friendRequests = 'friend_requests';
  static const String notifications = 'notifications';
  static const String watchHistory = 'watch_history';
  static const String joinRequests = 'join_requests';
  static const String premium = 'premium';
  static const String reports = 'reports';
  static const String appSettings = 'app_settings';
}
