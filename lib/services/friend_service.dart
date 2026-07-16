import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/firebase_error_mapper.dart';
import '../models/enums.dart';
import '../models/friend_model.dart';
import 'firestore_service.dart';

/// Friend-relationship operations spanning the `friend_requests` and
/// `friends` collections.
///
/// A request lives in `friend_requests` while pending; accepting it is a
/// batched move — delete from `friend_requests`, create in `friends` — so
/// the two collections never disagree about a relationship's state.
class FriendService {
  FriendService(this._firestoreService, [FirebaseFirestore? firestore])
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirestoreService _firestoreService;
  final FirebaseFirestore _db;

  Future<FriendModel> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    if (fromUserId == toUserId) {
      throw const DomainException('You can\'t send a friend request to yourself.');
    }
    final String id = FriendModel.buildId(userIdA: fromUserId, userIdB: toUserId);

    final existingFriend =
        await _firestoreService.getDocument(FirestoreCollections.friends, id);
    if (existingFriend != null) {
      throw const DomainException('You\'re already friends.');
    }
    final existingRequest =
        await _firestoreService.getDocument(FirestoreCollections.friendRequests, id);
    if (existingRequest != null) {
      throw const DomainException('A friend request already exists.');
    }

    final request = FriendModel(
      id: id,
      userId: fromUserId,
      friendId: toUserId,
      status: FriendStatus.pending,
      requestedBy: fromUserId,
      createdAt: DateTime.now(),
    );
    await _firestoreService.setDocument(
      FirestoreCollections.friendRequests,
      id,
      request.toMap(),
    );
    return request;
  }

  /// Moves the request from `friend_requests` to `friends` with
  /// `status: accepted`, atomically.
  Future<void> acceptFriendRequest({
    required String userIdA,
    required String userIdB,
  }) async {
    final String id = FriendModel.buildId(userIdA: userIdA, userIdB: userIdB);
    try {
      await _db.runTransaction((transaction) async {
        final requestRef =
            _db.collection(FirestoreCollections.friendRequests).doc(id);
        final requestSnap = await transaction.get(requestRef);
        if (!requestSnap.exists) {
          throw const DomainException('This friend request no longer exists.');
        }

        final friendRef = _db.collection(FirestoreCollections.friends).doc(id);
        final accepted = FriendModel.fromMap(id, requestSnap.data()!)
            .copyWith(status: FriendStatus.accepted, updatedAt: DateTime.now());

        transaction.set(friendRef, accepted.toMap());
        transaction.delete(requestRef);
      });
    } on DomainException {
      rethrow;
    } catch (e) {
      throw FirebaseErrorMapper.mapFirestoreError(e);
    }
  }

  Future<void> declineFriendRequest({
    required String userIdA,
    required String userIdB,
  }) async {
    final String id = FriendModel.buildId(userIdA: userIdA, userIdB: userIdB);
    await _firestoreService.deleteDocument(FirestoreCollections.friendRequests, id);
  }

  Future<void> removeFriend({required String userIdA, required String userIdB}) async {
    final String id = FriendModel.buildId(userIdA: userIdA, userIdB: userIdB);
    await _firestoreService.deleteDocument(FirestoreCollections.friends, id);
  }

  Future<void> blockUser({required String userId, required String blockedUserId}) async {
    final String id = FriendModel.buildId(userIdA: userId, userIdB: blockedUserId);
    final blocked = FriendModel(
      id: id,
      userId: userId,
      friendId: blockedUserId,
      status: FriendStatus.blocked,
      requestedBy: userId,
      createdAt: DateTime.now(),
    );
    await _firestoreService.setDocument(
      FirestoreCollections.friends,
      id,
      blocked.toMap(),
      merge: false,
    );
  }

  /// All accepted friendships involving [userId] — the relationship is
  /// stored once per pair, so this matches on either side of it.
  Stream<List<FriendModel>> streamFriends(String userId) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where(
                Filter.or(
                  Filter('userId', isEqualTo: userId),
                  Filter('friendId', isEqualTo: userId),
                ),
              )
              .where('status', isEqualTo: FriendStatus.accepted.name),
          FirestoreCollections.friends,
        )
        .map((docs) => docs.map((d) => FriendModel.fromMap(d['id'] as String, d)).toList());
  }

  /// Pending requests where [userId] is the *recipient* (i.e. requests
  /// waiting on this user to respond).
  Stream<List<FriendModel>> streamIncomingRequests(String userId) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('friendId', isEqualTo: userId)
              .where('status', isEqualTo: FriendStatus.pending.name),
          FirestoreCollections.friendRequests,
        )
        .map((docs) => docs.map((d) => FriendModel.fromMap(d['id'] as String, d)).toList());
  }

  /// Pending requests where [userId] is the *sender* (i.e. requests this
  /// user is waiting on someone else to respond to) — the Friends
  /// screen's "Sent Requests" tab and the Add Friend screen's "Request
  /// Sent" button state both read this.
  Stream<List<FriendModel>> streamOutgoingRequests(String userId) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('requestedBy', isEqualTo: userId)
              .where('status', isEqualTo: FriendStatus.pending.name),
          FirestoreCollections.friendRequests,
        )
        .map((docs) => docs.map((d) => FriendModel.fromMap(d['id'] as String, d)).toList());
  }

  /// Users [userId] has *themself* blocked. Filtered on `requestedBy`
  /// (the blocker) rather than `userId`/`friendId` alone, since a
  /// blocked-pair document doesn't otherwise say which side initiated
  /// the block — and only the initiator should see the entry in their
  /// own "Blocked" list.
  Stream<List<FriendModel>> streamBlockedUsers(String userId) {
    return _firestoreService
        .streamQuery(
          (ref) => ref
              .where('requestedBy', isEqualTo: userId)
              .where('status', isEqualTo: FriendStatus.blocked.name),
          FirestoreCollections.friends,
        )
        .map((docs) => docs.map((d) => FriendModel.fromMap(d['id'] as String, d)).toList());
  }

  /// Reverses [blockUser] — simply deletes the blocked-pair document, the
  /// same way [removeFriend] deletes an accepted one.
  Future<void> unblockUser({required String userId, required String blockedUserId}) async {
    final String id = FriendModel.buildId(userIdA: userId, userIdB: blockedUserId);
    await _firestoreService.deleteDocument(FirestoreCollections.friends, id);
  }
}
