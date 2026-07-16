import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/join_request_model.dart';
import '../models/room_model.dart';
import 'auth_state_provider.dart';
import 'repository_providers.dart';

/// Live public rooms for the Home screen's "Public Rooms" section — see
/// `RoomRepository.streamPublicRooms`'s doc comment for why this is a
/// stream rather than the one-shot `getPublicRooms` used elsewhere.
/// `autoDispose` so the listener is dropped once Home is popped.
final AutoDisposeStreamProvider<List<RoomModel>> publicRoomsStreamProvider =
    StreamProvider.autoDispose<List<RoomModel>>((ref) {
  return ref.watch(roomRepositoryProvider).streamPublicRooms(limit: 20);
});

/// The signed-in user's own pending join request for a given room, if
/// any — drives the real "Waiting for admin approval" state on a
/// Public Rooms card. `null` while signed out or with no pending
/// request. See `RoomRepository.streamMyJoinRequestForRoom`.
final AutoDisposeStreamProviderFamily<JoinRequestModel?, String> myJoinRequestForRoomProvider =
    StreamProvider.autoDispose.family<JoinRequestModel?, String>((ref, roomId) {
  final String? uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream<JoinRequestModel?>.value(null);
  return ref.watch(roomRepositoryProvider).streamMyJoinRequestForRoom(roomId: roomId, userId: uid);
});
