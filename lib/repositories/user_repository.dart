import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Reads/writes `users` documents for users *other than* the
/// mechanics of signing in/out — that belongs to [AuthRepository]. This
/// is profile data: viewing another user, updating your own profile
/// fields, presence, and FCM token bookkeeping.
class UserRepository {
  UserRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<UserModel?> getUser(String uid) async {
    final data = await _firestoreService.getDocument(FirestoreCollections.users, uid);
    return data == null ? null : UserModel.fromMap(uid, data);
  }

  Stream<UserModel?> streamUser(String uid) {
    return _firestoreService
        .streamDocument(FirestoreCollections.users, uid)
        .map((data) => data == null ? null : UserModel.fromMap(uid, data));
  }

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
    String? bio,
    String? language,
  }) {
    final Map<String, dynamic> updates = {
      if (displayName != null) 'displayName': displayName,
      if (displayName != null) 'displayNameLowercase': displayName.toLowerCase(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (bio != null) 'bio': bio,
      if (language != null) 'language': language,
    };
    if (updates.isEmpty) return Future.value();
    return _firestoreService.updateDocument(FirestoreCollections.users, uid, updates);
  }

  Future<void> updateNotificationPreferences({
    required String uid,
    bool? roomInvitations,
    bool? friendRequests,
    bool? appUpdates,
  }) {
    final Map<String, dynamic> updates = {
      if (roomInvitations != null) 'notifyRoomInvitations': roomInvitations,
      if (friendRequests != null) 'notifyFriendRequests': friendRequests,
      if (appUpdates != null) 'notifyAppUpdates': appUpdates,
    };
    if (updates.isEmpty) return Future.value();
    return _firestoreService.updateDocument(FirestoreCollections.users, uid, updates);
  }

  Future<void> setOnlineStatus({required String uid, required bool isOnline}) {
    return _firestoreService.updateDocument(FirestoreCollections.users, uid, {
      'isOnline': isOnline,
      'lastSeenAt': DateTime.now(),
    });
  }

  Future<void> addFcmToken({required String uid, required String token}) {
    return _firestoreService.updateDocument(FirestoreCollections.users, uid, {
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<void> removeFcmToken({required String uid, required String token}) {
    return _firestoreService.updateDocument(FirestoreCollections.users, uid, {
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }

  /// Simple prefix search on `displayName`. Firestore has no full-text
  /// search, so this relies on a `>=`/`<` range — fine for a "find a
  /// friend by name" box, not a substring/fuzzy search.
  Future<List<UserModel>> searchByDisplayNamePrefix(String prefix) async {
    if (prefix.isEmpty) return const [];
    final results = await _firestoreService.runQuery(
      (ref) => ref
          .orderBy('displayName')
          .startAt([prefix]).endAt(['$prefix\uf8ff']).limit(20),
      FirestoreCollections.users,
    );
    return results.map((d) => UserModel.fromMap(d['id'] as String, d)).toList();
  }

  /// The same prefix search as [searchByDisplayNamePrefix], but
  /// case-insensitive via the `displayNameLowercase` field (see
  /// [UserModel.displayNameLowercase]) — the Add Friend screen's real
  /// search uses this one so "raj" finds "Raj Patel".
  ///
  /// IMPORTANT: only users who've been written *since*
  /// `displayNameLowercase` was added (new sign-ups, or anyone who's
  /// since edited their profile via [updateProfile]) have this field
  /// set — Firestore can't query on a field that doesn't exist on a
  /// document, so older accounts simply won't surface here until a
  /// one-time backfill (see the delivery report) populates it. Callers
  /// should pass an already-lowercased [prefix].
  Future<List<UserModel>> searchByDisplayNameLowercasePrefix(String prefix, {int limit = 20}) async {
    if (prefix.isEmpty) return const [];
    final results = await _firestoreService.runQuery(
      (ref) => ref
          .orderBy('displayNameLowercase')
          .startAt([prefix]).endAt(['$prefix\uf8ff']).limit(limit),
      FirestoreCollections.users,
    );
    return results.map((d) => UserModel.fromMap(d['id'] as String, d)).toList();
  }
}
