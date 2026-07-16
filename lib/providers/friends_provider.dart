import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friend_model.dart';
import '../models/user_model.dart';
import 'auth_state_provider.dart';
import 'repository_providers.dart';

/// The current user's accepted friends, resolved to full [UserModel]
/// profiles (name, avatar, online status) rather than the bare
/// [FriendModel] relationship rows `FriendRepository.streamFriends`
/// returns.
///
/// Used by Create Room's "Friends (Optional)" picker, which needs to
/// display and search real profile fields — a screen further down the
/// funnel than anything `FriendRepository` alone exposes today. Kept as
/// its own provider (rather than inlined in the screen) so any future
/// "invite friends" surface can reuse the same join.
///
/// Takes the *first* snapshot of the friends list and resolves it once;
/// a friend accepted mid-session won't appear until this provider is
/// re-read (e.g. by leaving and reopening Create Room). That's an
/// acceptable trade-off for a picker inside a single create-room
/// session, versus a full `StreamProvider` that would have to re-run
/// the profile joins on every relationship-collection write.
final FutureProvider<List<UserModel>> friendsWithProfilesProvider =
    FutureProvider<List<UserModel>>((ref) async {
  final String? currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) return const [];

  final List<FriendModel> friendships =
      await ref.watch(friendRepositoryProvider).streamFriends(currentUserId).first;

  final userRepository = ref.watch(userRepositoryProvider);
  final List<UserModel?> profiles = await Future.wait(
    friendships.map((friendship) {
      final String otherUserId =
          friendship.userId == currentUserId ? friendship.friendId : friendship.userId;
      return userRepository.getUser(otherUserId);
    }),
  );

  return profiles.whereType<UserModel>().toList();
});
