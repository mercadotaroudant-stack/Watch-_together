import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../models/friend_model.dart';
import '../models/user_model.dart';
import 'auth_state_provider.dart';
import 'repository_providers.dart';

/// A friend resolved to their live profile, plus when the friendship was
/// formed (needed for the "Recently Added" sort — [UserModel] alone has
/// no notion of that, it's a property of the relationship, not the
/// person).
class FriendProfile extends Equatable {
  const FriendProfile({required this.user, required this.friendsSince});

  final UserModel user;
  final DateTime friendsSince;

  @override
  List<Object?> get props => [user, friendsSince];
}

/// An incoming friend request resolved to the requester's live profile,
/// plus a mutual-friends count.
class FriendRequestDisplay extends Equatable {
  const FriendRequestDisplay({
    required this.request,
    required this.requester,
    required this.mutualFriendsCount,
  });

  final FriendModel request;
  final UserModel requester;
  final int mutualFriendsCount;

  @override
  List<Object?> get props => [request, requester, mutualFriendsCount];
}

/// The current user's accepted friends, live — unlike
/// `friendsWithProfilesProvider` (a one-shot join used by pickers), this
/// recombines whenever the relationship list changes *or* any individual
/// friend's profile document changes (their `isOnline`/`lastSeenAt`
/// included), via `Rx.combineLatestList` over each friend's
/// `streamUser`. That's what lets the Friends screen show presence
/// changes and new/removed friendships live, with no manual refresh.
final StreamProvider<List<FriendProfile>> liveFriendsProvider =
    StreamProvider<List<FriendProfile>>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);

  final friendRepo = ref.watch(friendRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  return friendRepo.streamFriends(uid).switchMap((relations) {
    if (relations.isEmpty) return Stream.value(const <FriendProfile>[]);

    final List<Stream<UserModel?>> streams =
        relations.map((r) => userRepo.streamUser(r.userId == uid ? r.friendId : r.userId)).toList();

    return Rx.combineLatestList<UserModel?>(streams).map((users) {
      final List<FriendProfile> result = [];
      for (int i = 0; i < users.length; i++) {
        final UserModel? user = users[i];
        if (user == null) continue;
        result.add(FriendProfile(user: user, friendsSince: relations[i].updatedAt ?? relations[i].createdAt));
      }
      return result;
    });
  });
});

/// Incoming (pending, addressed-to-me) friend requests, live, each
/// resolved to the requester's profile and a mutual-friends count.
///
/// The mutual-friends count is computed from a one-shot snapshot of both
/// sides' friend lists rather than a live join — it's a small
/// informational detail on a request card, not something that needs to
/// visibly tick as friendships change mid-glance, so the extra
/// complexity of a fully live intersection isn't worth it here.
final StreamProvider<List<FriendRequestDisplay>> liveFriendRequestsProvider =
    StreamProvider<List<FriendRequestDisplay>>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);

  final friendRepo = ref.watch(friendRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  return friendRepo.streamIncomingRequests(uid).asyncMap((requests) async {
    final List<FriendRequestDisplay> result = [];
    final List<FriendModel> myFriends = await friendRepo.streamFriends(uid).first;
    final Set<String> myFriendIds =
        myFriends.map((f) => f.userId == uid ? f.friendId : f.userId).toSet();

    for (final FriendModel request in requests) {
      final String requesterId = request.requestedBy;
      final UserModel? requester = await userRepo.getUser(requesterId);
      if (requester == null) continue;

      int mutual = 0;
      try {
        final List<FriendModel> theirFriends = await friendRepo.streamFriends(requesterId).first;
        final Set<String> theirFriendIds =
            theirFriends.map((f) => f.userId == requesterId ? f.friendId : f.userId).toSet();
        mutual = myFriendIds.intersection(theirFriendIds).length;
      } catch (_) {
        // Best-effort — a mutual-count failure shouldn't hide the request.
      }

      result.add(FriendRequestDisplay(request: request, requester: requester, mutualFriendsCount: mutual));
    }
    return result;
  });
});

/// Outgoing (pending, sent-by-me) friend requests, live, each resolved
/// to the recipient's profile — the Friends screen's "Sent Requests" tab.
final StreamProvider<List<FriendProfile>> liveSentRequestsProvider =
    StreamProvider<List<FriendProfile>>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);

  final friendRepo = ref.watch(friendRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  return friendRepo.streamOutgoingRequests(uid).switchMap((requests) {
    if (requests.isEmpty) return Stream.value(const <FriendProfile>[]);
    final List<Stream<UserModel?>> streams =
        requests.map((r) => userRepo.streamUser(r.friendId)).toList();

    return Rx.combineLatestList<UserModel?>(streams).map((users) {
      final List<FriendProfile> result = [];
      for (int i = 0; i < users.length; i++) {
        final UserModel? user = users[i];
        if (user == null) continue;
        result.add(FriendProfile(user: user, friendsSince: requests[i].createdAt));
      }
      return result;
    });
  });
});

/// Users the current user has blocked, live, resolved to profiles.
final StreamProvider<List<FriendProfile>> liveBlockedUsersProvider =
    StreamProvider<List<FriendProfile>>((ref) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);

  final friendRepo = ref.watch(friendRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  return friendRepo.streamBlockedUsers(uid).switchMap((relations) {
    if (relations.isEmpty) return Stream.value(const <FriendProfile>[]);
    final List<Stream<UserModel?>> streams =
        relations.map((r) => userRepo.streamUser(r.userId == uid ? r.friendId : r.userId)).toList();

    return Rx.combineLatestList<UserModel?>(streams).map((users) {
      final List<FriendProfile> result = [];
      for (int i = 0; i < users.length; i++) {
        final UserModel? user = users[i];
        if (user == null) continue;
        result.add(FriendProfile(user: user, friendsSince: relations[i].createdAt));
      }
      return result;
    });
  });
});
