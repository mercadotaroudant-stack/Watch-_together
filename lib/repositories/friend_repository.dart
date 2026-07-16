import '../models/friend_model.dart';
import '../services/friend_service.dart';

/// Typed entry point for friend requests and friendships. A thin pass
/// through to [FriendService] — the composite/transactional logic
/// (accept = move between collections, etc.) already lives there; this
/// layer exists so callers depend on a `Repository`, consistent with
/// every other feature, rather than reaching into a `Service` directly.
class FriendRepository {
  FriendRepository(this._friendService);

  final FriendService _friendService;

  Future<FriendModel> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  }) =>
      _friendService.sendFriendRequest(fromUserId: fromUserId, toUserId: toUserId);

  Future<void> acceptFriendRequest({required String userIdA, required String userIdB}) =>
      _friendService.acceptFriendRequest(userIdA: userIdA, userIdB: userIdB);

  Future<void> declineFriendRequest({required String userIdA, required String userIdB}) =>
      _friendService.declineFriendRequest(userIdA: userIdA, userIdB: userIdB);

  Future<void> removeFriend({required String userIdA, required String userIdB}) =>
      _friendService.removeFriend(userIdA: userIdA, userIdB: userIdB);

  Future<void> blockUser({required String userId, required String blockedUserId}) =>
      _friendService.blockUser(userId: userId, blockedUserId: blockedUserId);

  Future<void> unblockUser({required String userId, required String blockedUserId}) =>
      _friendService.unblockUser(userId: userId, blockedUserId: blockedUserId);

  Stream<List<FriendModel>> streamFriends(String userId) =>
      _friendService.streamFriends(userId);

  Stream<List<FriendModel>> streamIncomingRequests(String userId) =>
      _friendService.streamIncomingRequests(userId);

  Stream<List<FriendModel>> streamOutgoingRequests(String userId) =>
      _friendService.streamOutgoingRequests(userId);

  Stream<List<FriendModel>> streamBlockedUsers(String userId) =>
      _friendService.streamBlockedUsers(userId);
}
